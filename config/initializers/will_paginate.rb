# config/initializers/will_paginate.rb
require 'will_paginate/array'
require 'will_paginate/view_helpers/action_view'

module WillPaginate
  module ActionView
    class PatternflyLinkRenderer < LinkRenderer
      protected

      def container_attributes
        super.except(:first_label, :last_label)
      end

      def pagination
        [:back, :pages, :forward]
      end

      def back
        tag :ul, first_page + previous_page, class: 'pagination pagination-pf-back'
      end

      def forward
        tag :ul, next_page + last_page, class: 'pagination pagination-pf-forward'
      end

      def pages
        current_page_input = tag(:input, '', class: 'pagination-pf-page', type: 'text', value: current_page, id: 'cur_page_num')
        current_page_label = tag(:label, _('Current Page'), class: 'sr-only', for: 'cur_page_num')
        of_total_pages = tag(:span, _('of ') + tag(:span, total_pages, class: 'pagination-pf-pages'))
        current_page_input + current_page_label + of_total_pages
      end

      def first_page
        previous_or_next_page(current_page == 1 ? nil : 1, @options[:first_label], 'first_page')
      end

      def last_page
        previous_or_next_page(current_page == total_pages ? nil : total_pages, @options[:last_label], 'last_page')
      end

      def previous_or_next_page(page, text, classname)
        classname = [classname, ('disabled' unless page)].join(' ')
        tag :li, link(text, page || '#'), class: classname
      end
    end
  end
end
