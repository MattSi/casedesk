class TodayController < ApplicationController
  def show
    @now = Current.firm.now
    @overdue_tasks = Current.user.assigned_tasks.overdue(@now).includes(matter: :client).order(:due_at)
  end
end
