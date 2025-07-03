# frozen_string_literal: true

class CloneOperatingSystem
  class << self
    def clone_obj(orig_obj, new_attrs = {})
      new_obj = orig_obj.deep_clone include: associations, except: [:title, :description]
      new_obj.assign_attributes(new_attrs)

      new_obj
    end

    # Search for the OS candidate to clone
    # The search is based on the OS name and the major and optionally the minor version
    # OS with the same major take precedence over OS with lower major
    def find_candidate_to_clone(name, major, minor = nil)
      check_existing_os(name, major, minor)

      return find_by_major(name, major) if minor.empty?

      find_by_release(name, major, minor)
    end

    private

    def associations
      [:media, :ptables, :architectures, :os_parameters, :provisioning_templates, :os_default_templates]
    end

    def check_existing_os(name, major, minor = nil)
      search_params = { name: name, major: major }
      search_params[:minor] = minor if minor.present?

      raise Foreman::Exception.new(N_("Operating system already exists")) if Operatingsystem.find_by(search_params)
    end

    def find_by_major(name, major)
      Operatingsystem.where("name = ? AND CAST(major AS INTEGER) < ?", name, major).sort_by_version.last
    end

    def find_by_release(name, major, minor)
      oss = Operatingsystem.where("name = ? AND CAST(major AS INTEGER) <= ?", name, major).sort_by_version
      same_major = oss.select { |os| os.major == major && os.minor < minor }

      return same_major.last if same_major.any?

      oss.reverse.find { |os| os.major < major }
    end
  end
end
