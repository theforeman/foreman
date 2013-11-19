require 'test_helper'

class SystemMailerTest < ActionMailer::TestCase
  def setup
    disable_orchestration
    @system = systems(:one)
    @env = environments(:production)
    as_admin do
      @system.last_report = Time.at(0)
      @system.save(:validate => false)
      @env.systems << @system
      @env.save
    end
    User.current = User.admin
    Setting[:foreman_url] = "http://localsystem:3000/systems/:id"

    @options = {}
    @options[:env] = @env
  end

  test "mail should have the specified recipient" do
    @options[:email] = "ltolchinsky@vurbiatechnologies.com"
    assert SystemMailer.summary(@options).deliver.to.include?("ltolchinsky@vurbiatechnologies.com")
  end

  test "mail should have admin as recipient if email is not defined" do
    @options[:email] = nil
    Setting[:administrator] = "admin@vurbia.com"
    assert SystemMailer.summary(@options).deliver.to.include?("admin@vurbia.com")
  end

  test "mail should have a subject" do
    assert !SystemMailer.summary(@options).deliver.subject.empty?
  end

  test "mail should have a body" do
    assert !SystemMailer.summary(@options).deliver.body.empty?
  end

  # TODO: add an assertion checking the presence of a fact filter.
  test "mail should contain a filter if it's defined" do
    @options[:env] = @env
    assert SystemMailer.summary(@options).body.include?(@env.name)
  end

  test "mail should have the system for the specific filter" do
    @options[:env] = @env
    assert SystemMailer.summary(@options).deliver.body.include?(@system.name)
  end

  test "mail should display the filter for the specific fact" do
    @options[:env] = nil
    @options[:factname] = "Kernel"
    @options[:factvalue] = "Linux"
    fn = FactName.create :name => @options[:factname]
    FactValue.create :value => @options[:factvalue], :fact_name => fn, :system => @system
    assert SystemMailer.summary(@options).deliver.body.include?(@options[:factname])
  end

  test "mail should report at least one system" do
    assert SystemMailer.summary(@options).deliver.body.include?(@system.name)
  end

  test "mail should report disabled systems" do
    @system.enabled = false
    @system.save
    assert SystemMailer.summary(@options).deliver.body.include?(@system.name)
  end

end
