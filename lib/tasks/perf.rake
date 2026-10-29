namespace :perf do
  FIRM_NAME = "Perf Test LLP"

  desc "Load about 1 million tasks into a separate firm for performance testing"
  task seed: :environment do
    abort "Run this in development only" unless Rails.env.development?
    abort "#{FIRM_NAME} already exists. Run bin/rails perf:clear first." if Firm.exists?(name: FIRM_NAME)

    ActiveRecord::Base.logger = nil
    started = Time.current
    now = Time.current
    firm = Firm.create!(name: FIRM_NAME)

    # 200 users. A few of them (like senior partners) get most of the tasks.
    digest = BCrypt::Password.create("password")
    User.insert_all(200.times.map { |i|
      { firm_id: firm.id, name: "Perf User #{i}", email_address: "perf-#{i}@example.com",
        password_digest: digest, created_at: now, updated_at: now }
    })
    user_ids = User.where(firm: firm).order(:id).ids

    Contact.insert_all(2_000.times.map { |i|
      { firm_id: firm.id, name: "Client #{i}", created_at: now, updated_at: now }
    })
    contact_ids = Contact.where(firm: firm).ids

    Matter.insert_all(10_000.times.map { |i|
      { firm_id: firm.id, client_id: contact_ids.sample, number: format("%05d", i + 1),
        title: "Matter #{i + 1}", status: "open", created_at: now, updated_at: now }
    })
    matter_ids = Matter.where(firm: firm).ids

    # rand**2 is skewed toward 0, so the first users get many more rows
    pick_user = -> { user_ids[(rand**2 * user_ids.size).floor] }

    # 1,000,000 tasks: 90% completed over the last 5 years, 10% open around today
    100.times do |batch|
      rows = 10_000.times.map do
        if rand < 0.9
          due = now - rand(5 * 365 * 24 * 3600)
          status, completed_at = "completed", due
        else
          due = now + rand(-60 * 24 * 3600..60 * 24 * 3600)
          status, completed_at = "open", nil
        end
        { firm_id: firm.id, matter_id: matter_ids.sample, assignee_id: pick_user.call,
          title: "Task #{batch}", due_at: due, status: status, completed_at: completed_at,
          created_at: now, updated_at: now }
      end
      Task.insert_all(rows)
      print "\rtasks: #{(batch + 1) * 10_000}"
    end
    puts

    # 200,000 calendar events over the last 2 years and the next 2 months
    20.times do |batch|
      rows = 10_000.times.map do
        starts = now + rand(-2 * 365 * 24 * 3600..60 * 24 * 3600)
        { firm_id: firm.id, user_id: pick_user.call, matter_id: matter_ids.sample,
          title: "Event #{batch}", starts_at: starts, ends_at: starts + 3600,
          created_at: now, updated_at: now }
      end
      CalendarEvent.insert_all(rows)
      print "\revents: #{(batch + 1) * 10_000}"
    end
    puts

    puts "Done in #{(Time.current - started).round}s. Busiest user: perf-0@example.com " \
         "(#{Task.where(assignee_id: user_ids.first).count} tasks)"
  end

  desc "Time the Today page queries for the busiest perf user"
  task today: :environment do
    ActiveRecord::Base.logger = nil
    user = User.find_by!(email_address: "perf-0@example.com")
    now = user.firm.now
    next_7_days = now..(now + 6.days).end_of_day

    queries = {
      "overdue (all)" => user.assigned_tasks.overdue(now).order(:due_at),
      "overdue (top 10)" => user.assigned_tasks.overdue(now).order(:due_at).limit(10),
      "upcoming tasks" => user.assigned_tasks.due_between(next_7_days).order(:due_at),
      "upcoming events" => user.calendar_events.starting_between(next_7_days)
    }

    queries.each do |name, relation|
      relation.reload # warm up
      times = 20.times.map do
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        relation.reload # reload runs the query again instead of using cached records
        (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000
      end
      median = times.sort[times.size / 2]
      puts "#{name.ljust(17)} #{relation.size.to_s.rjust(5)} rows  median #{median.round(1).to_s.rjust(6)} ms"
    end

    puts
    queries.each do |name, relation|
      puts "EXPLAIN #{name}:"
      puts relation.explain.inspect
      puts
    end
  end

  desc "Delete the perf firm and all of its data"
  task clear: :environment do
    abort "Run this in development only" unless Rails.env.development?
    firm = Firm.find_by(name: FIRM_NAME) or abort "Nothing to clear"
    [ CalendarEvent, Task, Matter, Contact ].each do |model|
      model.where(firm_id: firm.id).in_batches(of: 50_000).delete_all
    end
    Session.where(user_id: User.where(firm_id: firm.id).select(:id)).delete_all
    User.where(firm_id: firm.id).delete_all
    firm.delete
    puts "Cleared #{FIRM_NAME}"
  end
end
