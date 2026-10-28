require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "requires a name" do
    assert_not Contact.new(firm: firms(:harbor)).valid?
  end

  test "lists the matters where the contact is the client" do
    assert_includes contacts(:harrington).matters, matters(:harrington_termination)
  end

  test "cannot be deleted while it has matters" do
    assert_not contacts(:harrington).destroy
    assert contacts(:harrington).errors.any?
  end
end
