module Foreman
  class LdapAvatarMigrator
    def initialize(apply: false, output: $stdout)
      @apply = apply
      @output = output
    end

    def run
      counts = { :copied => 0, :planned => 0, :skipped => 0, :missing => 0, :failed => 0 }
      User.unscoped.where.not(:avatar_hash => [nil, '']).find_each do |user|
        result = migrate(user)
        counts[result] += 1
        @output.puts "User #{user.id}: #{result}"
      rescue StandardError => error
        counts[:failed] += 1
        @output.puts "User #{user.id}: failed (#{error.class})"
      end
      @output.puts counts.map { |name, count| "#{name}=#{count}" }.join(' ')
      counts
    end

    private

    def migrate(user)
      return :skipped if user.avatar.attached?

      path = user.legacy_avatar_path
      return :missing unless path

      content = path.binread
      content_type = Marcel::MimeType.for(StringIO.new(content))
      raise ActiveStorage::IntegrityError unless ['image/jpeg', 'image/png'].include?(content_type)
      return :planned unless @apply

      copied = user.update_ldap_avatar(content, :skip_existing => true)
      raise ActiveStorage::IntegrityError if copied == false

      copied ? :copied : :skipped
    end
  end
end
