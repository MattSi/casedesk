require "test_helper"

class TodayHelperTest < ActionView::TestCase
  test "greeting depends on the hour" do
    assert_equal "Good morning", greeting(Time.zone.parse("2026-10-28 09:00"))
    assert_equal "Good afternoon", greeting(Time.zone.parse("2026-10-28 14:00"))
    assert_equal "Good evening", greeting(Time.zone.parse("2026-10-28 21:00"))
  end
end
