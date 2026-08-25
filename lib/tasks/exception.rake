require 'net/http'
require 'json'
require 'erb'

desc 'Exception utilities'
namespace :exception do
  desc 'List all error codes'
  task codes: :environment do
    puts generate_error_codes_list
  end

  desc 'Update the ErrorCodes wiki page on projects.theforeman.org'
  task wiki: :environment do
    api_key = ENV['FOREMAN_REDMINE_API_KEY']
    raise "FOREMAN_REDMINE_API_KEY environment variable is not set" unless api_key

    I18n.with_locale(:en) do
      # Get existing error codes from wiki
      existing_error_codes = fetch_existing_error_codes(api_key)
      puts "Found #{existing_error_codes.size} existing error codes on wiki"

      # Collect current error codes from codebase
      current_error_codes = collect_error_codes.to_h
      puts "Found #{current_error_codes.size} error codes in current instance"

      # Merge: current overrides existing, but keep orphaned existing ones
      merged_error_codes = existing_error_codes.merge(current_error_codes).sort

      content = generate_error_codes_wiki_content(merged_error_codes)
      update_wiki_page(api_key, 'ErrorCodes', content)
      puts "Successfully updated ErrorCodes wiki page (#{merged_error_codes.size} total codes)"
    end
  end

  task default: :codes

  private

  def fetch_existing_error_codes(api_key)
    uri = URI("https://projects.theforeman.org/projects/foreman/wiki/ErrorCodes.json")
    request = Net::HTTP::Get.new(uri)
    request['X-Redmine-API-Key'] = api_key

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.code.to_i >= 200 && response.code.to_i < 300
      raise "Failed to fetch ErrorCodes wiki page: #{response.code} #{response.message}"
    end

    data = JSON.parse(response.body)
    text = data.dig('wiki_page', 'text') || ''

    # Parse lines like: * [[ERF12-1234]] - Error message here
    error_codes = {}
    text.each_line do |line|
      if line =~ /\* \[\[([^\]]+)\]\] - (.+)$/
        code = Regexp.last_match(1)
        message = Regexp.last_match(2).strip
        error_codes[code] = message
      end
    end

    error_codes
  end

  def collect_error_codes
    exceptions = [
      'Foreman::Exception',
      'WrappedException',
      'ProxyException',
    ]
    result = {}
    regexp = /raise.*(#{exceptions.join('|')})(\.new)?.*N_\(?(["'])([^\3]+?)\3\)?\)?/
    Dir['app/**/*rb', 'lib/**/*rb'].each do |path|
      File.open(path) do |f|
        f.grep(/#{regexp}/) do |line|
          code = ::Foreman::Exception.calculate_error_code Regexp.last_match(1), Regexp.last_match(4)
          result[code] = Regexp.last_match(4)
        end
      end
    end

    result.sort
  end

  def generate_error_codes_list
    error_codes = collect_error_codes

    template = ERB.new(<<~TEMPLATE, trim_mode: '-')
      <% error_codes.each do |code, message| -%>
      * [[<%= code %>]] - <%= message %>
      <% end -%>
    TEMPLATE

    template.result(binding)
  end

  def generate_error_codes_wiki_content(error_codes)
    template = ERB.new(<<~TEMPLATE, trim_mode: '-')
      h1. Foreman error codes

      Most error messages in Foreman include error code. Find additional information by clicking on individual codes on this page.

      If you have an ERF12-* error, do check [[Proxy_communication_errors]] first for SSL or communication errors, which aren't specific to particular proxy actions.

      <% error_codes.each do |code, message| -%>
      * [[<%= code %>]] - <%= message %>
      <% end -%>

      Do not edit. Generated via _rake exception:wiki_.
    TEMPLATE

    template.result(binding)
  end

  def update_wiki_page(api_key, page_name, content)
    uri = URI("https://projects.theforeman.org/projects/foreman/wiki/#{page_name}.json")
    request = Net::HTTP::Put.new(uri)
    request['Content-Type'] = 'application/json'
    request['X-Redmine-API-Key'] = api_key

    wiki_page_data = {
      text: content,
      comments: "Generated via rake exception:wiki",
    }

    request.body = { wiki_page: wiki_page_data }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.code.to_i >= 200 && response.code.to_i < 300
      raise "Failed to update wiki page #{page_name}: #{response.code} #{response.message}\n#{response.body}"
    end
  end
end
