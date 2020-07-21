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
          @report_data = []
          @report_headers = []
        end

        apipie :method, 'Render a report for all rows defined' do
          desc 'This macro is typically called at the end of the report template, after all rows
            with data has been registered.'
          keyword :format, ReportTemplateFormat.all.map(&:id), desc: 'The desired format of output', default: ReportTemplateFormat.default.id
          keyword :order, String, desc: "The desired order of the reported data. It needs to be the name of the column or an array of more of them, e.g. <code>'name'</code> or <code>['ip', 'name']</code>. If no order is specified, the report will be sorted by the order of report_row calls.", default: nil
          keyword :reverse_order, [true, false], desc: 'Reverse the order of the reported data', default: false
          returns String, desc: 'This is the resulting report'
          example "report_render # => 'name,ip\nhost1.example.com,192.168.0.2\nhost2.example.com,192.168.0.3'"
          example "report_render(format: :yaml) # => '---\n- name: host1.example.com\n  ip: 192.168.0.2\n- name: host2.example.com\n  ip: 192.168.0.3'"
          example "report_render(order: :ip)  # => \n#'name,ip\n#host1.example.com,192.168.0.2\n#host2.example.com,192.168.0.3'"
          example "report_render(order: [:name, :ip]) # => \n#'name,ip\n#host1.example.com,192.168.0.2\n#host2.example.com,192.168.0.3'"
          example "report_render(order: :ip, reverse_order: true) # => \n#'name,ip\n#host2.example.com,192.168.0.3\n#host1.example.com,192.168.0.2'"
        end
        def report_render(format: report_format&.id, order: nil, reverse_order: false)
          apply_order!(order) if order.present?
          @report_data.reverse! if reverse_order

          case format
          when :csv, :txt, nil
            report_render_csv
          when :yaml
            report_render_yaml
          when :json
            report_render_json
          when :html
            report_render_html
          end
        end

        apipie :method, 'Register minimal headers for the report' do
          desc "Report template gathers the column names when report_row is called. However, if the method is not ever called, e.g. because the collection is empty, the report wouldn't have any headers. This macro allows to explicitly define expected headers. If new header is registered by report_row, it's just added to the list of known headers."
          list :headers, desc: 'List of headers'
          returns Array, desc: 'Minimal registered headers'
          example "<%- report_headers 'id', 'name' -%>"
        end
        def report_headers(*headers)
          @report_headers = headers.map(&:to_s)
        end

        apipie :method, 'Register a row of data for the report' do
          desc "For every record that should be part of the report, **report_row** macro needs to be called.
            The only argument it accepts is a record definition. This is typically called in some **each** loop. Calling
            this at least once is important so we know what columns are to be rendered in this report.
            Calling this macro adds a record to the rendering queue."
          required :row_data, Hash, desc: 'Data in form of hash, keys are column names, values are values for this record'
          returns Array, desc: 'Currently registered report data'
          example "report_row(:name => 'host1.example.com', :ip => '192.168.0.2')"
          example "<%- load_hosts.each_record do |host|\n  report_row(:name => host.name, :ip => host.ip)\nend -%>"
        end
        def report_row(row_data)
          new_headers = row_data.keys
          if @report_headers.size < new_headers.size
            @report_headers |= new_headers.map(&:to_s)
          end
          @report_data << row_data.values
        end

        def apply_order!(order)
          order = [order].flatten.map(&:to_s)
          if (unknown = order - @report_headers).present?
            raise UnknownReportColumn.new(:unknown => unknown.join(', '))
          end

          indexes = order.map { |column| @report_headers.index(column) }
          @report_data.sort_by! do |values|
            indexes.map { |i| values[i] }
          end
        end

        def allowed_helpers
          @allowed_helpers ||= super + [:report_row, :report_render, :report_format, :report_headers]
        end

        def report_format
          @params[:format]
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

        def report_render_csv
          CSV.generate(headers: true, encoding: Encoding::UTF_8) do |csv|
            csv << @report_headers
            @report_data.each do |row|
              csv << row.map { |cell| serialize_cell(cell) }
            end
          end
        end

        def report_render_html
          html = ""

          html << "<html><head><title>#{@template_name}</title><style>#{html_style}</style></head><body><table><thead><tr>"
          html << @report_headers.map { |header| "<th>#{ERB::Util.html_escape(header)}</th>" }.join('')
          html << "</tr></thead><tbody>"

          @report_data.each do |row|
            html << "<tr>"
            html << row.map { |cell| "<td>#{ERB::Util.html_escape(cell)}</td>" }.join('')
            html << "</tr>"
          end
          html << "</tbody></table></body></html>"

          html
        end

        def html_style
          <<~CSS
            th { background-color: black; color: white; }
            table,th,td { border-collapse: collapse; border: 1px solid black; }
          CSS
        end

        def serialize_cell(cell)
          if cell.is_a?(Enumerable)
            cell.map(&:to_s).join(',')
          else
            cell.to_s
          end
        end

        def valid_yaml_type(cell)
          if cell.is_a?(String) || [true, false].include?(cell) || cell.is_a?(Numeric) || cell.nil?
            cell
          elsif cell.is_a?(Enumerable)
            cell.map { |item| valid_yaml_type(item) }
          else
            cell.to_s
          end
        end

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
