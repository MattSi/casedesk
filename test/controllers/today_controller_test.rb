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
end
