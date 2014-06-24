require 'test_helper'

class SeedsTest < ActiveSupport::TestCase
  # Disable AR transactional fixtures as we use DatabaseCleaner's truncation
  # to empty the DB of fixtures for testing the seed script
  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.clean_with :truncation
    Setting.expects(:[]).with(:administrator).at_least_once.returns("root@localhost")
  end

  def seed
    admin = User.new(:login => 'testadmin')
    admin.admin = true
    User.current = admin
    load File.expand_path('../../../../db/seeds.rb', __FILE__)
  end

  teardown do
    User.current = nil
  end

  test 'populates features' do
    count = Feature.count
    seed
    assert_not_equal count, Feature.count
  end

  test 'populates an admin user' do
    assert_difference 'User.where(:login => "admin").count', 1 do
      seed
    end
    user = User.find_by_login('admin')
    assert_present user.password_hash
    assert_present user.password_salt
    assert user.admin?
    assert user.valid?, "User not valid: #{user.errors.full_messages.to_sentence}"
  end

  test 'populates partition tables' do
    count = Ptable.count
    seed
    assert_not_equal count, Ptable.count
    refute Ptable.where(:os_family => nil).any?
  end

  test 'populates installation media' do
    count = Medium.count
    seed
    assert_not_equal count, Medium.count
    refute Medium.where(:os_family => nil).any?
  end

  test 'populates config templates' do
    count = ConfigTemplate.count
    seed
    assert_not_equal count, ConfigTemplate.count

    Dir["#{Rails.root}/app/views/unattended/**/*.erb"].each do |tmpl|
      if tmpl =~ /disklayout/
        assert Ptable.where(:layout => File.read(tmpl)).any?, "No partition table containing #{tmpl}"
      else
        assert ConfigTemplate.where(:template => File.read(tmpl)).any?, "No template containing #{tmpl}"
      end
    end
  end

  test 'populates bookmarks' do
    count = Bookmark.where(:public => true).count
    seed
    assert_not_equal count, Bookmark.where(:public => true).count
  end

  test 'is idempotent' do
    seed
    ActiveRecord::Base.any_instance.expects(:save).never
    seed
  end

  test "doesn't add a template back that was deleted" do
    seed
    assert_equal 1, ConfigTemplate.destroy_all(:name => 'Kickstart default').size
    seed
    refute ConfigTemplate.find_by_name('Kickstart default')
  end

  test "doesn't add a template back that was renamed" do
    seed
    tmpl = ConfigTemplate.find_by_name('Kickstart default')
    tmpl.name = 'test'
    tmpl.save!
    seed
    refute ConfigTemplate.find_by_name('Kickstart default')
  end

  test "no audits are recorded" do
    seed
    assert_equal [], Audit.all
  end
end
