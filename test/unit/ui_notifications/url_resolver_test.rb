require 'test_helper'

class UINotificationsTest < ActiveSupport::TestCase
  test 'should parse a hard coded url' do
    actions = {links: [{href: '/static_path', title: 'some hard coded url'}] }
    resolver = UINotifications::URLResolver.new(subject, actions)
    assert_equal actions, resolver.actions
  end

  test 'should parse a dynamic url for a given subject' do
    subject = FactoryBot.build(:host)
    actions = {links: [{path_method: :host_path, title: 'link_to_host'}] }
    resolver = UINotifications::URLResolver.new(subject, actions)
    assert_equal resolver.actions, {links: [{href: "/hosts/#{subject}", title: 'link_to_host'}]}
  end

  test 'should parse a url title for a given subject' do
    subject = FactoryBot.build(:host)
    actions = {links: [{path_method: :edit_host_path, title: "edit %{subject}"}] }
    resolver = UINotifications::URLResolver.new(subject, actions)
    assert_equal resolver.actions, {links: [{href: "/hosts/#{subject}/edit", title: "edit #{subject}"}]}
  end

  test 'it should not accept path_method that does not edit with _path' do
    actions = {links: [{path_method: :somewhere, title: 'aha'}] }
    assert_raise(Foreman::Exception) { UINotifications::URLResolver.new(subject, actions).actions }
  end

  test 'it should not accept path_method that does not edit with _path' do
    actions = {links: [{path_method: :somewhere, title: 'aha'}] }
    assert_raise(Foreman::Exception) { UINotifications::URLResolver.new(subject, actions).actions }
  end

  test 'it should not accept empty titles' do
    actions = {links: [{href: '/somewhere'}] }
    assert_raise(Foreman::Exception) { UINotifications::URLResolver.new(subject, actions).actions }
  end

  test 'it should link to a collection url' do
    actions = {links: [{path_method: :bookmarks_path, title: 'bookmarks'}] }
    resolver = UINotifications::URLResolver.new(subject, actions)
    assert_equal resolver.actions, {links: [{href: "/bookmarks", title: "bookmarks"}]}
  end
end
