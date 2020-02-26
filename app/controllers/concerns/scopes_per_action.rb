# This module will hold a registry of scope directives that should be
# part of the query per specific action in a controller. This is required by
# plugins that add *_to_many relations to foreman core models like
# `Host::Managed` and want to add some includes or eager_load directives to
# the query.

module ScopesPerAction
  extend ActiveSupport::Concern

  # returns a scope that includes all directives registered via add_scope_for
  def action_scope_for(action, base_scope)
    scope = base_scope
    self.class.scopes_for(action).each do |scope_func|
      scope = scope_func.call(scope) || scope
    end
    scope
  end

  module ClassMethods
    # Add a new scope directive to action specified by action parameter using
    # block statement. It will receive the base scope as a first parameter.
    # example: add_scope_for(:my_action) { |base_scope| base_scope.includes(:my_new_table) }
    def add_scope_for(action, &block)
      local_scopes_for(action) << block
    end

    def scopes_for(action)
      all_scopes = scopes_per_action.merge(scopes_per_action_from_plugins) { |k, left_v, right_v| left_v + right_v }
      all_scopes[action] || []
    end

    def local_scopes_for(action)
      scopes_per_action[action] ||= []
    end

    private

    def scopes_per_action
      @scopes_per_action ||= {}
    end

    def scopes_per_action_from_plugins
      Foreman::Plugin.all.map { |plugin| plugin.action_scopes_hash_for(self) }.inject({}) do |memo, actions_hash|
        memo.merge(actions_hash) { |k, left_v, right_v| left_v + right_v }
      end
    end
  end
end
