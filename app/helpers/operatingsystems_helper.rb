module OperatingsystemsHelper

  # displays release name on debian based distributions on operating system edit page.
  def show_release
    update_page do |page|
      page << "if (value == 'Debian') {"
      page[:release_name].show
      page[:release_name].highlight
      page << "} else {"
      page[:release_name].hide
      page << "}"
    end
  end

  # If we use form_for @operatingsystem then we get errors because redhat_path is not available.
  # If we use form_for :operatingsystem alone then we get the wrong urls generated
  def family_url os
    (request.symbolized_path_parameters[:action] =~ /create|new/) ? operatingsystems_path : operatingsystem_path(os)
  end

  def family_html_method
    (request.symbolized_path_parameters[:action] =~ /creatre|new/) ? :post : :put
  end

end
