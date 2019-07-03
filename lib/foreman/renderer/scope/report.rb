module Foreman
  module Renderer
    module Scope
      class Report < Foreman::Renderer::Scope::Template
        def initialize(**args)
          super
          @report_data = []
          @report_headers = []
        end

        def report_render(format: report_format&.id)
          case format
          when :csv, :txt, nil
            report_render_csv
          when :yaml
            report_render_yaml
          when :json
            report_render_json
          end
        end

        def report_row(row_data)
          @report_headers = row_data.keys.map(&:to_s) if @report_headers.empty?
          @report_data << row_data.values
        end

        def allowed_helpers
          @allowed_helpers ||= super + [ :report_row, :report_render, :report_format ]
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
