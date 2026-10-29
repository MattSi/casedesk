require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "overdue lists open tasks past their due date only" do
    overdue = Task.overdue
    assert_includes overdue, tasks(:review_settlement)
    assert_includes overdue, tasks(:review_motion)
    assert_not_includes overdue, tasks(:call_client)   # due in the future
    assert_not_includes overdue, tasks(:old_intake)    # already completed
  end

  test "a user's overdue tasks stay inside their firm" do
    emily_overdue = users(:emily).assigned_tasks.overdue
    assert_equal 2, emily_overdue.count
    assert_not_includes emily_overdue, tasks(:lakeside_task)
  end

  test "complete! marks the task done and records when" do
    task = tasks(:review_settlement)
    task.complete!
    assert task.completed?
    assert_not_nil task.completed_at
    assert_not task.overdue?
  end

  test "days overdue counts whole days" do
    assert_equal 2, tasks(:review_settlement).days_overdue
    assert_equal 0, tasks(:call_client).days_overdue
  end

  test "takes the firm from its matter" do
    task = Task.create!(matter: matters(:harrington_termination), assignee: users(:emily), title: "Draft reply")
    assert_equal firms(:harbor), task.firm
  end

  test "assignee must belong to the same firm" do
    task = Task.new(matter: matters(:harrington_termination), assignee: users(:omar), title: "Wrong person")
    assert_not task.valid?
    assert_includes task.errors[:assignee], "must belong to the same firm"
  end
end
