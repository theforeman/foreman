require 'test_helper'

class HomeHelperTest < ActionView::TestCase
  def test_menu_item_tag
    item = Menu::Item.new(:test_good_menu, :url_hash => {:controller=>'hosts', :action=>'index'}, :after => :me, :turbolinks => false)
    tag = menu_item_tag(item)

    assert tag.include?('data-no-turbolink')
  end
end
