require 'test_helper'

class UINotificationsTest < ActiveSupport::TestCase
  test 'should parse a messsage with a subject' do
    subject = FactoryBot.build(:host)
    template = "hello %{subject}"
    options = {subject: subject}
    resolver = UINotifications::StringParser.new(template, options)
    assert_equal "hello #{subject}", resolver.to_s
  end

  test 'should parse a messsage with a subject twice' do
    subject = FactoryBot.build(:host)
    template = "hello %{subject} / %{subject}"
    options = {subject: subject}
    resolver = UINotifications::StringParser.new(template, options)
    assert_equal "hello #{subject} / #{subject}", resolver.to_s
  end
end
