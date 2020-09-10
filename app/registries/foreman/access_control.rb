# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module Foreman
  module AccessControl
    class << self
      def map
        mapper = Mapper.new
        yield mapper
        @permissions ||= []
        @permissions += mapper.mapped_permissions
      end

      attr_reader :permissions

      def permissions_for_controller_action(controller_action)
        controller_action = path_hash_to_string(controller_action) if controller_action.is_a?(Hash) || controller_action.is_a?(ActionController::Parameters)
        @permissions.select { |p| p.actions.include?(controller_action) }
      end

      def normalize_path_hash(hash)
        hash[:controller] = hash[:controller].to_s.gsub(/::/, "_").underscore
        hash[:controller] = hash[:controller][1..-1] if hash[:controller].starts_with?('/')
        hash
      end

      def path_hash_to_string(hash)
        "#{hash[:controller]}/#{hash[:action]}"
      end

      # Returns the permission of given name or nil if it wasn't found
      # Argument should be a symbol
      def permission(name)
        permissions.detect { |p| p.name == name }
      end

      # Removes the permission object given from the control list
      def remove_permission(permission)
        !!@permissions.delete(permission)
      end

      # Returns the actions that are allowed by the permission of given name
      def allowed_actions(permission_name)
        perm = permission(permission_name)
        perm ? perm.actions : []
      end

      def public_permissions
        @public_permissions ||= @permissions.select { |p| p.public? }
      end

      def members_only_permissions
        @members_only_permissions ||= @permissions.select { |p| p.require_member? }
      end

      def loggedin_only_permissions
        @loggedin_only_permissions ||= @permissions.select { |p| p.require_loggedin? }
      end

      def available_security_blocks
        @available_security_blocks ||= @permissions.collect(&:security_block).uniq.compact
      end

      def blocks_permissions(modules)
        @permissions.select { |p| p.security_block.nil? || modules.include?(p.security_block.to_s) }
      end
    end

    class Mapper
      def initialize
        @security_block = nil
      end

      def permission(name, hash, options = {})
        @permissions ||= []
        options[:security_block] = @security_block if @security_block
        @permissions << Permission.new(name, hash, options)
      end

      def security_block(name, options = {})
        @security_block = name
        yield self
        @security_block = nil
      end

      def mapped_permissions
        @permissions
      end
    end

    class Permission
      attr_reader :name, :actions, :security_block, :resource_type, :engine

      def initialize(name, hash, options)
        @name = name
        @actions = []
        @public = options[:public] || false
        @require = options[:require]
        @security_block = options[:security_block]
        @resource_type = options[:resource_type]
        @engine = options[:engine]
        hash.each do |controller, actions|
          if actions.is_a? Array
            @actions << actions.collect { |action| "#{controller}/#{action}" }
          else
            @actions << "#{controller}/#{actions}"
          end
        end
        @actions.flatten!
      end

      def public?
        @public
      end

      def plugin?
        !!@engine
      end

      def require_member?
        @require && @require == :member
      end

      def require_loggedin?
        @require && (@require == :member || @require == :loggedin)
      end
    end
  end
end
