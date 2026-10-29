require "test_helper"

class Tasks::CompletionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:emily) }

  test "completes the task and removes its card" do
    task = tasks(:review_settlement)
    post task_completion_url(task), as: :turbo_stream

    assert_response :success
    assert task.reload.completed?
    assert_match %(<turbo-stream action="remove" target="#{dom_id(task)}">), response.body
    assert_no_match "Nothing overdue", response.body   # review_motion is still overdue
  end

  test "shows the empty message after the last overdue task" do
    tasks(:review_motion).complete!
    post task_completion_url(tasks(:review_settlement)), as: :turbo_stream

    assert_match %(<turbo-stream action="update" target="top_priority">), response.body
    assert_match "Nothing overdue", response.body
  end

  test "falls back to a redirect without Turbo" do
    post task_completion_url(tasks(:review_settlement))
    assert_redirected_to root_url
  end

  test "cannot complete someone else's task" do
    post task_completion_url(tasks(:lakeside_task)), as: :turbo_stream
    assert_response :not_found
    assert tasks(:lakeside_task).reload.open?
  end
end
