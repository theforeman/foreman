require 'test_helper'

class LoaderMacrosTest < ActiveSupport::TestCase
  setup do
    template = OpenStruct.new(
      name: 'Test',
      template: 'Test'
    )
    source = Foreman::Renderer::Source::Database.new(
      template
    )
    @scope = Class.new(Foreman::Renderer::Scope::Base) do
      include Foreman::Renderer::Scope::Macros::Base
    end.send(:new, source: source)
  end

  describe '#load_resources' do
    it 'should accept custom selects' do
      @scope.load_hosts(select: :id)
      @scope.load_hosts(select: [:id, :name])
    end

    it 'should reject unacceptable selects' do
      assert_raises(ArgumentError) { @scope.load_hosts(select: 'a string value') }
      assert_raises(ArgumentError) { @scope.load_hosts(select: {:key => :value}) }
      assert_raises(ArgumentError) { @scope.load_hosts(select: [:mixed, 'array']) }
      error = assert_raises(ArgumentError) { @scope.load_hosts(select: 7) }
      assert_match /Value of 'select'/, error.message
      assert_match /load_hosts/, error.message
      assert_match /Symbol or Array of Symbols/, error.message
    end

    it 'should accept custom joins' do
      @scope.load_hosts(joins: :interfaces)
      @scope.load_hosts(joins: {:interfaces => :subnet})
      @scope.load_hosts(joins: [:interfaces, :domain])
    end

    it 'should reject unacceptable joins' do
      assert_raises(ArgumentError) { @scope.load_hosts(joins: 'a string value') }
      assert_raises(ArgumentError) { @scope.load_hosts(joins: [:mixed, 'array']) }
      error = assert_raises(ArgumentError) { @scope.load_hosts(joins: 7) }
      assert_match /Value of 'joins'/, error.message
      assert_match /load_hosts/, error.message
      assert_match /Symbol, Hash or Array of Symbols/, error.message
    end
  end
end
