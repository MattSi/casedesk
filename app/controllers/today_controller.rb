class TodayController < ApplicationController
  def show
    @now = Current.firm.now
    tasks = Current.user.assigned_tasks.includes(matter: :client).order(:due_at)
    @overdue_tasks = tasks.overdue(@now).limit(10)

    next_7_days = @now..(@now + 6.days).end_of_day
    upcoming_tasks = tasks.due_between(next_7_days)
    upcoming_events = Current.user.calendar_events.starting_between(next_7_days).includes(matter: :client)

    @upcoming_days = (upcoming_tasks + upcoming_events)
                       .sort_by(&:scheduled_at)
                       .group_by { |item| item.scheduled_at.in_time_zone(@now.time_zone).to_date }
  end
end
