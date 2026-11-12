namespace :personal_access_tokens do
  desc 'Permanently delete inactive Personal Access Tokens, optionally older than DAYS'
  task :purge, [:days] => :environment do |_task, args|
    days = Integer(args[:days] || 0)
    raise ArgumentError, 'DAYS must not be negative' if days.negative?

    count = PersonalAccessToken.purge_inactive!(:before => days.days.ago)
    puts "Deleted #{count} inactive Personal Access Tokens"
  end
end
