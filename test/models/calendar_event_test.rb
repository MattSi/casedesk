require "test_helper"

class CalendarEventTest < ActiveSupport::TestCase
  test "takes the firm from its user" do
    event = CalendarEvent.create!(user: users(:emily), title: "Lunch with client",
                                  starts_at: 1.day.from_now, ends_at: 1.day.from_now + 1.hour)
    assert_equal firms(:harbor), event.firm
  end

  test "a matter is optional" do
    assert calendar_events(:team_meeting).valid?
  end

  test "must end after it starts" do
    event = calendar_events(:mediation)
    event.ends_at = event.starts_at
    assert_not event.valid?
    assert_includes event.errors[:ends_at], "must be after the start time"
  end

  test "matter must belong to the same firm" do
    event = calendar_events(:mediation)
    event.matter = matters(:nguyen_contract)
    assert_not event.valid?
    assert_includes event.errors[:matter], "must belong to the same firm"
  end

  test "starting_between finds events in the range" do
    events = CalendarEvent.starting_between(Time.current..7.days.from_now)
    assert_includes events, calendar_events(:mediation)
    assert_not_includes events, calendar_events(:past_conference)
    assert_not_includes events, calendar_events(:omar_call)
  end
end
