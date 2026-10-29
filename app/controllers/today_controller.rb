class TodayController < ApplicationController
  def show
    @now = Current.firm.now
    tasks = Current.user.assigned_tasks.includes(matter: :client).order(:due_at)

    @overdue_tasks = tasks.overdue(@now)
    @upcoming_days = tasks.due_between(@now..(@now + 6.days).end_of_day)
                          .group_by { |task| task.due_at.in_time_zone(@now.time_zone).to_date }
  end
end
