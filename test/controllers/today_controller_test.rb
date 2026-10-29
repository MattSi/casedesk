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
    assert_select "article", 2
    assert_select "##{dom_id(tasks(:review_settlement))}", /Review and approve Settlement Agreement/
    assert_select "##{dom_id(tasks(:review_settlement))}", /2d overdue/
    assert_select "##{dom_id(tasks(:review_settlement))}", /00014-Harrington/
    assert_no_match "Call client about mediation date", response.body   # not overdue yet
    assert_no_match "Collect intake documents", response.body           # completed
    assert_no_match "Send demand letter", response.body                 # other firm
  end

  test "shows an empty message when nothing is overdue" do
    sign_in_as users(:omar)
    tasks(:lakeside_task).complete!
    get root_url
    assert_select "article", 0
    assert_match "Nothing overdue", response.body
  end
end
