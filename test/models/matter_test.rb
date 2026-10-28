require "test_helper"

class MatterTest < ActiveSupport::TestCase
  test "assigns the next number within the firm" do
    matter = firms(:harbor).matters.create!(client: contacts(:harrington), title: "Second claim")
    assert_equal "00023", matter.number
  end

  test "numbers are counted per firm" do
    matter = firms(:lakeside).matters.create!(client: contacts(:nguyen), title: "Another contract")
    assert_equal "00006", matter.number
  end

  test "client must belong to the same firm" do
    matter = firms(:harbor).matters.new(client: contacts(:nguyen), title: "Wrong firm")
    assert_not matter.valid?
    assert_includes matter.errors[:client], "must belong to the same firm"
  end

  test "status defaults to open and rejects unknown values" do
    matter = Matter.new(status: "archived")
    assert_not matter.valid?
    assert matter.errors[:status].any?
    assert Matter.new.open?
  end

  test "display name uses the number and client's last name" do
    assert_equal "00014-Harrington", matters(:harrington_termination).display_name
  end

  test "a firm only sees its own matters" do
    assert_includes firms(:harbor).matters, matters(:harrington_termination)
    assert_not_includes firms(:harbor).matters, matters(:nguyen_contract)
  end
end
