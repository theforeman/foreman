require 'test_helper'

class HostMailerTest < ActionMailer::TestCase
  def setup
    @env = Environment.new :name => "testing"
    @env.save!
    @host = Host.new :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => @env, :disk => "empty partition",
      :ptable => Ptable.first, :last_report => nil
    @host.save!
    @env.hosts << @host
    @env.save!
    @options = {}
  end

  test "mail should have the specified recipient" do
    @options[:env] = @env
    @options[:email] = "ltolchinsky@vurbiatechnologies.com"
    SETTINGS[:foreman_url] = "http://localhost:3000/hosts/:id"
    assert HostMailer.deliver_summary(@options).to.include?("ltolchinsky@vurbiatechnologies.com")
  end

  # test "mail should have admin as recipient" do
    # <++>
  # end

  # test "mail should have any recipient" do
    # <++>
  # end

  # test "mail should have a subject" do
    # <++>
  # end

  # test "mail should have a body" do
    # <++>
  # end

  # test "mail should contain a filter if it's defined" do
    # <++>
  # end

  # test "mail should report at least one host" do
    # <++>
  # end

  # test "should send an email" do
    # <++>
  # end
end
