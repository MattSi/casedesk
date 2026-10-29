require "test_helper"

class TodayControllerTest < ActionDispatch::IntegrationTest
  test "redirects to sign in when not logged in" do
    get root_url
    assert_redirected_to new_session_url
  end

  test "shows the user's name and firm when logged in" do
    sign_in_as users(:emily)
    get root_url
    assert_response :success
    assert_match "Emily Foster", response.body
    assert_match "Harbor &amp; Pine LLP", response.body
  end

  test "top priority shows my overdue tasks only" do
    sign_in_as users(:emily)
    get root_url
    assert_select "section h2", "Top priority"
    assert_select "#top_priority article", 2
    assert_select "##{dom_id(tasks(:review_settlement))}", /Review and approve Settlement Agreement/
    assert_select "##{dom_id(tasks(:review_settlement))}", /2d overdue/
    assert_select "##{dom_id(tasks(:review_settlement))}", /00014-Harrington/
    assert_select "##{dom_id(tasks(:review_settlement))} button", "Mark complete"
    top_priority = css_select("#top_priority").text
    assert_not_includes top_priority, "Call client about mediation date"   # not overdue yet
    assert_not_includes top_priority, "Collect intake documents"           # completed
    assert_not_includes top_priority, "Send demand letter"                 # other firm
  end

  test "shows an empty message when nothing is overdue" do
    sign_in_as users(:omar)
    tasks(:lakeside_task).complete!
    get root_url
    assert_select "article", 0
    assert_match "Nothing overdue", response.body
  end


  test "upcoming lists my open tasks for the next 7 days" do
    sign_in_as users(:emily)
    get root_url
    upcoming = css_select("#upcoming").text
    assert_includes upcoming, "Prepare mediation brief"            # tomorrow
    assert_includes upcoming, "Call client about mediation date"   # in 3 days
    assert_not_includes upcoming, "File notice of appeal"          # 20 days away
    assert_not_includes upcoming, "Review draft Motion"            # overdue, shown above
    assert_select "#upcoming ##{dom_id(tasks(:call_client))} button", "Mark complete"
  end

  test "upcoming shows an empty message" do
    sign_in_as users(:omar)
    get root_url
    assert_match "Nothing due in the next 7 days", response.body
  end
end
