require "test_helper"

class TodayHelperTest < ActionView::TestCase
  test "greeting depends on the hour" do
    assert_equal "Good morning", greeting(Time.zone.parse("2026-10-28 09:00"))
    assert_equal "Good afternoon", greeting(Time.zone.parse("2026-10-28 14:00"))
    assert_equal "Good evening", greeting(Time.zone.parse("2026-10-28 21:00"))
  end



  test "day label says Today, Tomorrow, or the date" do
    today = Date.new(2026, 10, 28)
    assert_equal "Today", day_label(today, today)
    assert_equal "Tomorrow", day_label(today + 1, today)
    assert_equal "Friday, October 30", day_label(today + 2, today)
  end
end
