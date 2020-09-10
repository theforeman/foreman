require 'test_helper'

class HashForTest < ActionView::TestCase
  test "hash_for_*_path returns expected elements" do
    assert_equal({:controller => 'hosts', :action => 'new', :use_route => 'new_host'}, hash_for_new_host_path)
  end

  test "hash_for_* doesn't memorize options" do
    assert_equal({:controller => 'audits', :action => 'index', :use_route => 'audits', :search => 'foo'}, hash_for_audits_path(:search => 'foo'))
    assert_equal({:controller => 'audits', :action => 'index', :use_route => 'audits'}, hash_for_audits_path)
  end

  test "hash_for_* causes link_to to generate links to root from within nested controller" do
    opts = url_options.merge(:_recall => {:controller => "foreman_example/examples", :action => "index"})
    expects(:url_options).returns(opts)
    assert_includes link_to('test', hash_for_hosts_path), 'href="/hosts"'
  end
end
