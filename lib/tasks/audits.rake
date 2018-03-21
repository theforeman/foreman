# TRANSLATORS: do not translate
desc <<-END_DESC
Expire old audits automatically

Available conditions:
  * days        => number of days to keep audits (defaults to 90)

  Example:
    rake audits:expire # expires all audits older then 90 days
    rake audits:expire days=7 # expires all audits older then 7 days

END_DESC

namespace :audits do
  task :expire => :environment do
    before = ENV['days'].to_i.days.ago if ENV['days']
    before ||= 90.days.ago
    audits = Audited::Audit.up_until(before)
    puts "Deleting audits older than #{before}. This might take a few minutes..."
    TaxableTaxonomy.where(taxable_type: "Audited::Audit", taxable: audits).delete_all
    count = audits.delete_all
    puts "Successfully deleted #{count} audits!"
  end
end
