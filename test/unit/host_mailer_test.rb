require 'test_helper'

class HostMailerTest < ActionMailer::TestCase
  def setup
    @host = hosts(:one)
    @env = environments(:production)
    as_admin do
      @host.last_report = Time.at(0)
      @host.save(:validate => false)
      @env.hosts << @host
      @env.save
    end
    User.current = User.admin
    Setting[:foreman_url] = "http://localhost:3000/hosts/:id"

    @options = {}
    @options[:env] = @env
  end

  test "mail should have the specified recipient" do
    @options[:email] = "ltolchinsky@vurbiatechnologies.com"
    assert HostMailer.summary(@options).deliver.to.include?("ltolchinsky@vurbiatechnologies.com")
  end

  test "mail should have admin as recipient if email is not defined" do
    @options[:email] = nil
    Setting[:administrator] = "admin@vurbia.com"
    assert HostMailer.summary(@options).deliver.to.include?("admin@vurbia.com")
  end

  test "mail should have a subject" do
    assert !HostMailer.summary(@options).deliver.subject.empty?
  end

  test "mail should have a body" do
    assert !HostMailer.summary(@options).deliver.body.empty?
  end

  # TODO: add an assertion checking the presence of a fact filter.
  test "mail should contain a filter if it's defined" do
    @options[:env] = @env
    assert HostMailer.summary(@options).body.include?(@env.name)
  end

  test "mail should have the host for the specific filter" do
    @options[:env] = @env
    assert HostMailer.summary(@options).deliver.body.include?(@host.name)
  end

  test "mail should display the filter for the specific fact" do
    @options[:env] = nil
    @options[:factname] = "Kernel"
    @options[:factvalue] = "Linux"
    fn = FactName.create :name => @options[:factname]
    FactValue.create :value => @options[:factvalue], :fact_name => fn, :host => @host
    assert HostMailer.summary(@options).deliver.body.include?(@options[:factname])
  end

  test "mail should report at least one host" do
    assert HostMailer.summary(@options).deliver.body.include?(@host.name)
  end

  test "mail should report disabled hosts" do
    @host.enabled = false
    @host.save
    assert HostMailer.summary(@options).deliver.body.include?(@host.name)
  end

end
