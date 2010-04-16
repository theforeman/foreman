module OperatingsystemsHelper

  # displays release name on debian based distributions on operating system edit page.
  def show_release
    update_page do |page|
      page << "if ($('operatingsystem_family_id').value == '#{Family::FAMILIES.index(:Debian)}') {"
      page[:release_name].show
      page[:release_name].highlight
      page << "} else {"
      page[:release_name].hide
      page << "}"
    end
  end
end
