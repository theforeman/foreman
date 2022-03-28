# TRANSLATORS: do not translate
desc <<~END_DESC
  Expire or anonymize old audits automatically. 
  The number of days can be easily defined in Settings or you can use "days" parameter.
  If both Setting and parameter are undefined, task finishes without cleaning any audits.
  Template audits are left uncleaned.

  Available conditions:
    * days        => number of days to keep audits (default can be defined in Settings)

    Example:
      rake audits:expire # expires all audits older then 90 days
      rake audits:expire days=7 # expires all audits older then 7 days
      rake audits:anonymize days=7 # anonymizes all audits older then 7 days

END_DESC

namespace :audits do
  task :expire => :environment do
    audits = get_audits_without_templates
    puts "Deleting audits older than #{before_date}. This might take a few minutes..."
    TaxableTaxonomy.where(taxable_type: "Audited::Audit", taxable: audits).delete_all
    count = audits.delete_all
    puts "Successfully deleted #{count} audits!"
  end

  task :anonymize => :environment do
    puts "Anonymizing audits older than #{before_date}. This might take a few minutes..."
    count = get_audits.where.not(:remote_address => nil, :user_id => nil, :username => nil)
      .update_all(:username => nil, :remote_address => nil, :user_id => nil)
    puts "Successfully anonymized #{count} audits!"
  end

  task :list_attributes => :environment do
    Foreman::Application.eager_load!

    # Only direct subclasses of ApplicationRecord, so we do not get all the STI like GroupParameter
    # Host is a different case as always, we want all the STI classes there.
    Host::Base.subclasses.concat(ApplicationRecord.subclasses).each do |ar|
      next unless ar.respond_to?(:non_audited_columns)
      docs = ApipieDSL.get_class_description(ar)&.docs || {}
      props_docs = docs[:properties] || []

      puts "=== #{docs[:name] || ar.name}"
      puts '|==='
      puts "| Attribute | Description\n\n"

      (ar.column_names - ar.non_audited_columns).each do |col|
        col_docs = props_docs.detect { |doc| doc[:name] == col.sub(/_id$/, '') } || {}
        puts "| #{col.humanize} | #{col_docs[:short_description].to_s.sub('|', '_')}"
      end
      puts "|===\n\n"
    end
  end

  def get_audits_without_templates
    User.as_anonymous_admin do
      Audited::Audit.up_until(before_date).where.not(auditable_type: %w(ReportTemplate Ptable ProvisioningTemplate JobTemplate))
    end
  end

  def before_date
    days = ENV['days'] || Setting[:audits_period]
    if days.blank?
      puts "The interval for keeping the Audits is not defined in the settings, exiting..."
      exit 0
    end
    @before_date ||= days.to_i.days.ago
  end
end
