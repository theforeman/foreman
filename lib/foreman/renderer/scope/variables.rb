module Foreman
  module Renderer
    module Scope
      module Variables
        def self.included(base)
          base.extend(ClassMethods)
        end

        def loaded
          @loaded ||= []
        end

        def loaders
          self.class.loaders
        end

        def load_variables
          loaders.each do |loader|
            if respond_to?(loader, true) && !loaded.include?(loader)
              send(loader)
              loaded << loader
            end
          end
        end

        module ClassMethods
          def loaders
            @loaders ||= []
          end

          def register_loader(loader_name)
            loaders << loader_name unless loaders.include?(loader_name)
          end
        end
      end
    end
  end
end
