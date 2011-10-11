# config/initializers/will_paginate.rb

module WillPaginate
  module ViewHelpers
    class BootstrapLinkRenderer < LinkRenderer

      def to_html
        links = @options[:page_links] ? visible_page_numbers.map {|n| page_link_or_span(n, '')} : []
        html  = add_prev_next(links).join(@options[:separator])
        @options[:container] ? @template.content_tag(:div, @template.content_tag(:ul, html), html_attributes) : html
      end

      protected

      # previous/next buttons
      def add_prev_next(links)
        prev_class = "prev"
        next_class = "next"
        prev_class += " disabled" if visible_page_numbers.first == current_page
        next_class += " disabled" if visible_page_numbers.last == current_page
        links.unshift page_link_or_span(visible_page_numbers.first == current_page ? current_page : @collection.previous_page, prev_class, @options[:previous_label])
        links.push page_link_or_span(visible_page_numbers.last == current_page ? current_page : @collection.next_page, next_class, @options[:next_label])
      end

      def page_link_or_span(page, span_class, text = nil)
        span_class ||=""
        span_class += " active"  if page and page == current_page
        page_link page, text ||= page.to_s, :rel => rel_value(page), :class => span_class
      end

      def page_link(page, text, attributes = {})
        @template.content_tag(:li, @template.link_to(text, url_for(page), attributes) ,attributes)
      end
    end
  end
end