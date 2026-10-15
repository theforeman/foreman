require 'net/http'
require 'json'
require 'erb'

namespace :settings do
  desc "Print an overview of all Foreman and plugin settings"
  task list: :environment do
    I18n.with_locale(:en) do
      puts generate_settings_list
    end
  end

  desc "Update the Settings wiki page on projects.theforeman.org"
  task wiki: :environment do
    api_key = ENV['FOREMAN_REDMINE_API_KEY']
    raise "FOREMAN_REDMINE_API_KEY environment variable is not set" unless api_key

    I18n.with_locale(:en) do
      all_settings = collect_settings

      # Get existing Setting_* pages from wiki and merge with new ones
      existing_setting_names = fetch_existing_wiki_settings(api_key)
      puts "Found #{existing_setting_names.size} existing setting pages on wiki"
      current_setting_names = all_settings.map(&:name)
      puts "Found #{current_setting_names.size} settings in current instance"
      all_setting_names = (existing_setting_names + current_setting_names).uniq.sort_by(&:downcase)

      # Update index page with merged list
      index_content = generate_index_content_from_names(all_setting_names)
      update_wiki_page(api_key, 'Settings', index_content)
      puts "Updated Settings index page (#{all_setting_names.size} total settings)"

      # Update individual setting pages only for currently loaded settings
      all_settings.each do |setting|
        page_name = "Setting_#{setting.name}"
        content = generate_setting_page_content(setting)
        update_wiki_page(api_key, page_name, content, parent: 'Settings')
        puts "Updated #{page_name}"
      end

      puts "Successfully updated all wiki pages"
    end
  end

  task default: :list

  private

  def fetch_existing_wiki_settings(api_key)
    uri = URI("https://projects.theforeman.org/projects/foreman/wiki/index.json")
    request = Net::HTTP::Get.new(uri)
    request['X-Redmine-API-Key'] = api_key

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.code.to_i >= 200 && response.code.to_i < 300
      raise "Failed to fetch wiki index: #{response.code} #{response.message}"
    end

    data = JSON.parse(response.body)
    data['wiki_pages']
      .select { |page| page['title']&.start_with?('Setting_') && page.dig('parent', 'title') == 'Settings' }
      .map { |page| page['title'].sub(/^Setting_/, '') }
  end

  def collect_settings
    registry = SettingRegistry.instance

    all_settings = []
    registry.categories.each_key do |category|
      registry.category_settings(category).each_value do |setting|
        next if setting.description.blank?
        all_settings << setting
      end
    end

    all_settings.sort_by { |s| s.name.downcase }
  end

  def generate_settings_list
    all_settings = collect_settings

    template = ERB.new(<<~TEMPLATE, trim_mode: '-')
      <% all_settings.each do |setting| -%>
      <% full_name = setting.full_name.present? ? " (\#{setting.full_name})" : "" -%>
      <%= setting.name %><%= full_name %>
      <% end -%>
    TEMPLATE

    template.result(binding)
  end

  def generate_index_content_from_names(setting_names)
    template = ERB.new(<<~TEMPLATE, trim_mode: '-')
      h1. Foreman and plugins settings

      <% setting_names.each do |name| -%>
      * [[Setting_<%= name %>|<%= name %>]]
      <% end -%>

      Do not edit. Generated via _rake settings:wiki_.
    TEMPLATE

    template.result(binding)
  end

  def generate_setting_page_content(setting)
    template = ERB.new(<<~TEMPLATE, trim_mode: '-')
      h1. Foreman setting: "<%= setting.full_name %>"

      *Name*: <%= setting.name %>

      <% if setting.full_name.present? -%>
      *Full name*: <%= setting.full_name %>

      <% end -%>
      *Description*: <%= setting.description %>

      *Type*: <%= setting.settings_type %>

      *Category*: <%= setting.category_label || setting.category_name %>

      <% if setting.context.present? -%>
      *Context*: <%= setting.context %>

      <% end -%>
      <% default_value = setting.default.nil? ? "(none)" : setting.default.to_s -%>
      *Default value*: <%= default_value %>

      <% current_value = setting.value.nil? ? "(none)" : setting.value.to_s -%>
      *Current value*: <%= current_value %>

      *Encrypted*: <%= setting.encrypted? ? 'Yes' : 'No' %>

      *Readonly*: <%= setting.readonly? ? 'Yes (overridden in settings.yaml)' : 'No' %>

      <% if setting.respond_to?(:select_values) && setting.select_values.present? -%>
      *Available options*:

      <% setting.select_values.each do |option| -%>
      <% option_text = option.is_a?(Array) ? "\#{option[1]} (\#{option[0]})" : option.to_s -%>
      * <%= option_text %>
      <% end -%>

      <% end -%>

      List of all [[Settings]]. Do not edit. Generated via _rake settings:wiki_.
    TEMPLATE

    template.result(binding)
  end

  def update_wiki_page(api_key, page_name, content, parent: nil)
    uri = URI("https://projects.theforeman.org/projects/foreman/wiki/#{page_name}.json")
    request = Net::HTTP::Put.new(uri)
    request['Content-Type'] = 'application/json'
    request['X-Redmine-API-Key'] = api_key

    wiki_page_data = {
      text: content,
      comments: "Generated via rake settings:wiki",
    }
    wiki_page_data[:parent_title] = parent if parent

    request.body = { wiki_page: wiki_page_data }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.code.to_i >= 200 && response.code.to_i < 300
      raise "Failed to update wiki page #{page_name}: #{response.code} #{response.message}\n#{response.body}"
    end
  end
end
