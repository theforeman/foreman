module Foreman
  module Renderer
    module Scope
      class Report < Foreman::Renderer::Scope::Template
        def initialize(**args)
          super
          @report_data = []
          @report_headers = []
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

        def report_headers(*headers)
          @report_headers = headers.map(&:to_s)
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
