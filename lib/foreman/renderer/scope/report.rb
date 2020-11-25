module Foreman
  module Renderer
    module Scope
      class Report < Foreman::Renderer::Scope::Template
        extend ApipieDSL::Class

        apipie :class, 'Macros specific for report rendering' do
          name 'Report'
          sections only: %w[all reports]
        end

        def initialize(**args)
          super
          @report_headers = []
        end

        apipie :method, 'Render a report for all rows defined' do
          desc 'This macro is typically called at the end of the report template, it closes the output stream.'
          keyword :format, ReportTemplateFormat.all.map(&:id), desc: 'DEPRECATED: Use format of the report'
          returns String, desc: 'Always returns an empty string for compatibility reasons'
          example "report_render # => 'name,ip\nhost1.example.com,192.168.0.2\nhost2.example.com,192.168.0.3'"
          example "report_render(format: :yaml) # => this is now deprecated, format can only be set globally"
        end
        def report_render(format: nil, order: nil, reverse_order: false)
          # Arguments format, order and reverse_order are deprecated.

          # Write footer, output stream must be closed by the caller and not here.
          # Make sure each call ends with a newline to flush the buffer.
          case report_format_id
          when :csv, :txt, nil
            # nothing to do
          when :yaml
            # TODO
          when :json
            # TODO
          when :html
            @output.write "</tbody></table></body></html>\n"
          end

          # Return an empty string for legacy templates which uses <%= report_render %>.
          ''
        end

        apipie :method, 'Write header section into the output stream' do
          desc "All reports must call this method first. The order matters if data is passed in arrays. Once headers have been sent new columns/elements cannot be added."
          list :headers, desc: 'List of headers'
          returns Array, desc: 'Minimal registered headers'
          example "<%- report_headers 'id', 'name' -%>"
        end
        def report_headers(*headers)
          @report_headers = headers.map(&:to_s)

          # each call must end with newline
          case report_format_id
          when :csv, :txt, nil
            csv_output.add_row @report_headers
          when :yaml
            # TODO
          when :json
            # TODO
          when :html
            @output.write "<html><head><title>#{@template_name}</title><style>#{html_style}</style></head><body><table><thead><tr>"
            @output.write @report_headers.map { |header| "<th>#{ERB::Util.html_escape(header)}</th>" }.join('')
            @output.write "</tr></thead><tbody>\n"
          end
          @report_headers
        end

        def hash_row_to_array(row_data)
          row = []
          @report_headers.each do |key|
            row.append(row_data[key.to_sym] || row_data[key])
          end
          row
        end

        apipie :method, 'Output new row to report stream.' do
          desc "For every record that should be part of the report, **report_row** macro needs to be called.
            The only argument it accepts is a record definition. This is typically called in some **each** loop. Calling
            this at least once is important so we know what columns are to be rendered in this report.
            It is recommended to use order-dependant Array instead of Hash for better performance."
          required :row_data, Object, desc: 'Data in form of array (preferred) or hash, keys are column names, values are values for this record'
          example "report_row(:name => 'host1.example.com', :ip => '192.168.0.2')"
          example "<%- load_hosts.each_record do |host|\n  report_row(:name => host.name, :ip => host.ip)\nend -%>"
        end
        def report_row(row_data)
          # each call must end with newline
          case report_format_id
          when :csv, :txt, nil
            if row_data.is_a? Array
              csv_output.add_row row_data
            else
              csv_output.add_row hash_row_to_array(row_data)
            end
          when :yaml
            # TODO
          when :json
            # TODO
          when :html
            @output.write '<tr>'
            if row_data.is_a? Array
              @output.write row_data.map { |cell| "<td>#{ERB::Util.html_escape(cell)}</td>" }.join('')
            else
              @output.write hash_row_to_array(row_data).map { |cell| "<td>#{ERB::Util.html_escape(cell)}</td>" }.join('')
            end
            @output.write "</tr>\n"
          end
          nil
        end

        def allowed_helpers
          @allowed_helpers ||= super + [:report_row, :report_render, :report_format, :report_headers]
        end

        def report_format
          @params[:format]
        end

        def report_format_id
          @report_format_id ||= report_format&.id
        end

        private

        def report_render_yaml
          @report_data.map do |row|
            valid_row = row.map { |cell| valid_yaml_type(cell) }
            Hash[@report_headers.zip(valid_row)]
          end.to_yaml
        end

        def report_render_json
          @report_data.map do |row|
            valid_row = row.map { |cell| valid_json_type(cell) }
            Hash[@report_headers.zip(valid_row)]
          end.to_json
        end

        # CSV module needs << instead of write to stream data. The class also adds
        # some logging capabilities.
        class LoggingStream
          def initialize(out)
            @out = out
          end

          def <<(str)
            write(str)
          end

          def write(str)
            return if str.empty?
            Rails.logger.debug "Streaming: #{str}"
            @out.write(str)
          end
        end

        def csv_output
          @csv_output ||= CSV.new(LoggingStream.new(@output), headers: true, encoding: Encoding::UTF_8)
        end

        def html_style
          <<~CSS
            th { background-color: black; color: white; }
            table,th,td { border-collapse: collapse; border: 1px solid black; }
          CSS
        end

        # TODO REMOVEME
        def valid_yaml_type(cell)
          if cell.is_a?(String) || [true, false].include?(cell) || cell.is_a?(Numeric) || cell.nil?
            cell
          elsif cell.is_a?(Enumerable)
            cell.map { |item| valid_yaml_type(item) }
          else
            cell.to_s
          end
        end

        # TODO REMOVEME
        def valid_json_type(cell)
          if cell.is_a?(String) || [true, false].include?(cell) || cell.is_a?(Numeric) || cell.nil?
            cell
          elsif cell.is_a?(Enumerable)
            hashify = cell.is_a?(Hash)
            cell = cell.map { |item| valid_json_type(item) }
            cell = cell.to_h if hashify
            cell
          else
            cell.to_s
          end
        end
      end
    end
  end
end
