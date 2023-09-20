module Foreman
  module Renderer
    module Scope
      module Macros
        module Transpilers
          extend ApipieDSL::Module

          apipie :method, "Calls ct transpiler, path and arguments configurable in settings" do
            required :input, String, desc: 'input YAML'
            # optional :validate_input, Boolean, desc: 'validate YAML input and throw parsing error (defaults true)'
            # optional :validate_output, Boolean, desc: 'validate JSON input and throw parsing error (defaults false)'
            raises error: Foreman::Exception, desc: "when binary not present or executable or during transpilation error"
            returns String, desc: 'output from the ct transpiler'
            example "transpile_coreos_linux_config(\"---\\nyaml: blah\") #=> JSON"
          end
          def transpile_coreos_linux_config(input, validate_input = true, validate_output = false)
            YAML.safe_load(input) if validate_input
            ct_command = [Setting[:ct_location]] + Setting[:ct_arguments]
            result = Foreman::CommandRunner.new(ct_command, input).run!
            JSON.parse(result) if validate_output
            result
          end

          apipie :method, "Calls fcct transpiler, path and arguments configurable in settings" do
            required :input, String, desc: 'input YAML'
            # optional :validate_input, Boolean, desc: 'validate YAML input and throw parsing error (defaults true)'
            # optional :validate_output, Boolean, desc: 'validate JSON input and throw parsing error (defaults false)'
            raises error: Foreman::Exception, desc: "when binary not present or executable or during transpilation error"
            returns String, desc: 'output from the fcct transpiler'
            example "transpile_coreos_linux_config(\"---\\nyaml: blah\") #=> JSON"
          end
          def transpile_fedora_coreos_config(input)
            fcct_command = [Setting[:fcct_location]] + Setting[:fcct_arguments]
            Foreman::CommandRunner.new(fcct_command, input).run!
          end
        end
      end
    end
  end
end
