require "test_helper"

class FirmTest < ActiveSupport::TestCase
  test "valid with a name and a known time zone" do
    assert Firm.new(name: "Test Firm", time_zone: "Pacific Time (US & Canada)").valid?
  end

  test "requires a name" do
    firm = Firm.new(name: "")
    assert_not firm.valid?
    assert_includes firm.errors[:name], "can't be blank"
  end

  test "rejects an unknown time zone" do
    firm = Firm.new(name: "Test Firm", time_zone: "Mars/Olympus")
    assert_not firm.valid?
    assert firm.errors[:time_zone].any?
  end

  test "defaults to Pacific time" do
    assert_equal "Pacific Time (US & Canada)", Firm.new.time_zone
  end

  test "now is in the firm's time zone" do
    assert_equal "Eastern Time (US & Canada)", firms(:lakeside).now.time_zone.name
  end
end
