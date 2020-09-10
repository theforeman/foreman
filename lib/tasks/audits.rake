# TRANSLATORS: do not translate
desc <<~END_DESC
  Expire or anonymize old audits automatically

  Available conditions:
    * days        => number of days to keep audits (defaults to 90)

    Example:
      rake audits:expire # expires all audits older then 90 days
      rake audits:expire days=7 # expires all audits older then 7 days
      rake audits:anonymize days=7 # anonymizes all audits older then 7 days

END_DESC

namespace :audits do
  task :expire => :environment do
    audits = get_audits
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

  def get_audits
    User.as_anonymous_admin do
      Audited::Audit.up_until(before_date)
    end
  end

  def before_date
    @before_date ||= ENV['days'] ? ENV['days'].to_i.days.ago : 90.days.ago
  end
end
