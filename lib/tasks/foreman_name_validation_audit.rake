desc <<-END_DESC
  List domains whose names do not match Net::Validations::DOMAIN_NAME_REGEXP.

  Examples:
    bundle exec rake foreman:audit_domain_names RAILS_ENV=production
END_DESC

namespace :foreman do
  task audit_domain_names: :environment do
    domain_re = Net::Validations::DOMAIN_NAME_REGEXP
    invalid_domains = 0
    domain_total = Domain.unscoped.count

    Domain.unscoped.find_each do |domain|
      next if domain.name =~ domain_re

      invalid_domains += 1
      puts "INVALID DOMAIN  id=#{domain.id}  name=#{domain.name}"
    end

    if invalid_domains.zero?
      puts "Domains: all #{domain_total} records match DOMAIN_NAME_REGEXP."
    else
      puts "Domains: #{invalid_domains} invalid (of #{domain_total} total)"
    end

    exit(invalid_domains.zero? ? 0 : 1)
  end
end
