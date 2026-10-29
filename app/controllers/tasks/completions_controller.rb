class Tasks::CompletionsController < ApplicationController
  def create
    @task = Current.user.assigned_tasks.find(params[:task_id])
    @task.complete!
    @overdue_left = Current.user.assigned_tasks.overdue(Current.firm.now).count

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end
end
