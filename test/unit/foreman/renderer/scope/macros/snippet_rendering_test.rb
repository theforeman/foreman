require 'test_helper'

class SnippetRenderingTest < ActiveSupport::TestCase
  setup do
    host = FactoryBot.build_stubbed(:host)
    @subject = Class.new(Foreman::Renderer::Scope::Base) do
      include Foreman::Renderer::Scope::Macros::SnippetRendering
    end.send(:new, host: host)
  end

  test "should render a snippet" do
    snippet = mock("snippet")
    snippet.stubs(:name).returns("test")
    snippet.stubs(:template).returns("content")
    snippet.stubs(:log_render_results?).returns(false)
    Template.expects(:where).with(:name => "test", :snippet => true).returns([snippet])
    assert_equal 'content', @subject.snippet('test')
  end

  test "should render a snippet with variables" do
    snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "A <%= @b + ' ' + @c -%> D")
    assert_equal 'A B C D', @subject.snippet(snippet.name, :variables => { :b => 'B', :c => 'C' })
  end

  test "should render a snippet_if_exists with variables" do
    snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "A <%= @b + ' ' + @c -%> D")
    assert_equal 'A B C D', @subject.snippet_if_exists(snippet.name, :variables => { :b => 'B', :c => 'C' })
  end

  test "should render a snippets with variables" do
    snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "A <%= @b + ' ' + @c -%> D")
    assert_equal 'A B C D', @subject.snippets(snippet.name, :variables => { :b => 'B', :c => 'C' })
  end

  test "should not raise error when snippet is not found" do
    Template.expects(:where).with(:name => "test", :snippet => true).returns([])
    assert_nil @subject.snippet_if_exists('test')
  end
end
