module OperatingSystemNaming
  extend ActiveSupport::Concern

  module ClassMethods
    # Find all operatingsystems that are duplicates of the given operating system according to all unique constraints
    def find_by_attributes(name: nil, major: nil, minor: nil, description: nil)
      where_attributes = {
        name: name,
        major: major,
        minor: minor,
      }.compact
      scope = where(where_attributes)
      scope = scope.or(where(description: description)) if description.present?
      scope.or(where(title: generate_title(**where_attributes.merge(description: description))))
    end

    def title_name
      "title".freeze
    end

    def generate_title(description:, name:, major:, minor:)
      to_label(description: description, name: name, major: major, minor: minor).to_s[0..254]
    end

    def to_label(description:, name:, major:, minor:)
      return description if description.present?
      fullname(name: name, major: major, minor: minor)
    end

    def fullname(name:, major:, minor:)
      "#{name} #{release(major: major, minor: minor)}"
    end

    def release(major:, minor:)
      "#{major}#{('.' + minor.to_s) if minor.present?}"
    end

    def find_by_to_label(str)
      os = find_by_description(str.to_s)
      return os if os
      name, version = str.split(" ")
      cond = {:name => name}
      if version
        (major, minor) = os_major_minor_from_version_str(name, version)
        cond[:major] = major if major
        cond[:minor] = minor if minor
      end
      find_by(cond)
    end

    def os_major_minor_from_version_str(os_name, version_str)
      if os_name == 'Ubuntu'
        x, y, minor = version_str.split('.', 3)
        major = "#{x}.#{y}"
      else
        major, minor = version_str.split('.')
      end
      [major, minor]
    end
  end
end
