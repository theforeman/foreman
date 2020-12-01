# TRANSLATORS: do not translate
desc <<~END_DESC
  Refresh templates rendering statuses for all managed hosts

    Example:
      rake templates_rendering_statuses:refresh

END_DESC

namespace :templates_rendering_statuses do
  task refresh: :environment do
    Host::Managed.where(managed: true).in_batches(of: 100) do |batch|
      batch.map do |host|
        puts "#{host} - Refreshing templates rendering status"
        host.refresh_statuses([HostStatus::TemplatesRenderingStatus])
        puts Rainbow("#{host} - Successfully refreshed templates rendering status").green
      rescue StandardError => e
        puts Rainbow("#{host} - Error while refreshing templates rendering status: #{e}").red
        puts Rainbow(e.backtrace.join("\n"))
        nil
      end
    end
  end
end
