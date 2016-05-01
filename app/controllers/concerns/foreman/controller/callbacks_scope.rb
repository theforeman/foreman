module Foreman::Controller::CallbacksScope
  extend ActiveSupport::Concern

  class ScopeClass
    attr_reader :result, :result_options

    def initialize
      @result_options = {}
    end

    def process_success(options = {}, merge_direction = :right)
      throw 'tried to set ambigous result' if @result == :error
      @result = :success
      merge_options options, merge_direction
    end

    def process_error(options = {}, merge_direction = :right)
      throw 'tried to set ambigous result' if @result == :success
      @result = :error
      merge_options options, merge_direction
    end

    private

    def merge_options(other, merge_direction)
      if merge_direction == :right
        @result_options.merge! other
      elsif merge_direction == :left
        @result_options = other.merge(@result_options)
      else
        throw "unknown direction: #{merge_direction}"
      end
    end
  end

  included do
    alias_method_chain :process_success, :scope
    alias_method_chain :process_error, :scope
  end

  def process_success_with_scope(options = {}, merge_direction = :right)
    @result_scope ||= ScopeClass.new

    @result_scope.process_success(options, merge_direction)
  end

  def process_error_with_scope(options = {}, merge_direction = :right)
    @result_scope ||= ScopeClass.new

    @result_scope.process_error(options, merge_direction)
  end

  def default_render(*args)
    if @result_scope
      if @result_scope.result == :success
        process_success_without_scope @result_scope.result_options
      else
        process_error_without_scope @result_scope.result_options
      end
    end

    super unless performed?
  end

  def successful?(callback_result)
    if callback_result
      @result_scope.nil? || @result_scope.result == :success
    else
      callback_result.nil? && (@result_scope.nil? || @result_scope.result == :success)
    end
  end
end
