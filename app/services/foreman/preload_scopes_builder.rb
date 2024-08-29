module Foreman
  class PreloadScopesBuilder
    attr_reader :original_model

    def initialize(original_model)
      @original_model = original_model
    end

    def scopes
      @scopes ||= begin
        (preload_scopes + Foreman::Plugin.all.map { |plugin| plugin.preload_scopes[original_model.to_s] }).flatten.compact.uniq
      end
    end

    private

    # Must return an Array
    # Can be defined on an ActiveRecord model's class to add custom scopes which can't be created automatically
    def preload_scopes
      original_model_scopes = original_model.try(:preload_scopes) || []
      (build_scopes(original_model)&.values || []) + original_model_scopes
    rescue => e
      Rails.logger.error('Could not automatically build scopes for preload:')
      Rails.logger.error(e.full_message)
      original_model_scopes
    end

    def build_scopes(model, ignore: [], assoc_name: nil)
      scopes = dependent_associations(model, ignore: ignore).map do |assoc|
        next if ignore.include?(assoc.name)

        dep_associations = dependent_associations(assoc.klass)
        if dep_associations.any?
          ignore += dep_associations.select { |to_ignore| to_ignore.options.key?(:through) }.map(&:name)
          ignore << assoc.name
          dep_scopes = build_scopes(assoc.klass, ignore: ignore, assoc_name: assoc.name)
          if assoc.options.key?(:through)
            deps = dependent_associations(assoc.source_reflection.klass, ignore: ignore)
            if deps.any?
              dep_scopes = build_scopes(assoc.source_reflection.klass, ignore: ignore, assoc_name: assoc.source_reflection_name)
              next { assoc.options[:through] => dep_scopes }
            else
              next { assoc.options[:through] => assoc.source_reflection_name }
            end
          end
          next dep_scopes
        end

        assoc.name
      end.compact

      scopes.empty? ? assoc_name : { assoc_name => scopes }
    end

    def dependent_associations(model, ignore: [])
      model.reflect_on_all_associations.select do |assoc|
        !ignore.include?(assoc.name) && (assoc.options.values & [:destroy, :delete_all, :destroy_async]).any?
      end
    end
  end
end
