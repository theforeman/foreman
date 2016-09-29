class PtablesController < TemplatesController
  include Foreman::Controller::Parameters::Ptable
  helper_method :documentation_anchor

  def documentation_anchor
    '4.4.4PartitionTables'
  end
end
