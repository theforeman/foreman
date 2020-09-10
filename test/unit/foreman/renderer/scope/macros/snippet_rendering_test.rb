require 'test_helper'

class SnippetRenderingTest < ActiveSupport::TestCase
  setup do
    host = FactoryBot.build_stubbed(:host)
    template = OpenStruct.new(
      name: 'Test',
      template: 'Test'
    )
    source = Foreman::Renderer::Source::Database.new(
      template
    )
    @scope = Class.new(Foreman::Renderer::Scope::Base) do
      include Foreman::Renderer::Scope::Macros::SnippetRendering
    end.send(:new, host: host, source: source)
  end

  test "should render a snippet" do
    snippet = FactoryBot.create(:provisioning_template, :snippet, template: 'content')
    assert_equal 'content', @scope.snippet(snippet.name)
  end

  test "should render nested snippets" do
    snippet1 = FactoryBot.create(:provisioning_template, :snippet, template: '<%= @template_name %>')
    snippet2 = FactoryBot.create(:provisioning_template, :snippet, template: "<%= snippet('#{snippet1.name}') %> <%= @template_name %>")
    snippet3 = FactoryBot.create(:provisioning_template, :snippet, template: "<%= snippet('#{snippet2.name}') %> <%= @template_name %>")
    assert_equal "#{snippet1.name} #{snippet2.name} #{snippet3.name}", @scope.snippet(snippet3.name)
  end

  test "should render a snippet with variables" do
    snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "A <%= @b + ' ' + @c -%> D")
    assert_equal 'A B C D', @scope.snippet(snippet.name, :variables => { :b => 'B', :c => 'C' })
  end

  test "should render a snippet_if_exists with variables" do
    snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "A <%= @b + ' ' + @c -%> D")
    assert_equal 'A B C D', @scope.snippet_if_exists(snippet.name, :variables => { :b => 'B', :c => 'C' })
  end

  test "should render a snippet with variables" do
    snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "A <%= @b + ' ' + @c -%> D")
    assert_equal 'A B C D', @scope.snippet(snippet.name, :variables => { :b => 'B', :c => 'C' })
  end

  test "should not raise error when snippet is not found" do
    Template.expects(:where).with(:name => "test", :snippet => true).returns([])
    assert_nil @scope.snippet_if_exists('test')
  end

  test "should render a snippet_if_exists without variables" do
    snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "test")
    assert_equal 'test', @scope.snippet_if_exists(snippet.name)
  end
end
