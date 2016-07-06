class LocationsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::TaxonomiesController
  include Foreman::Controller::Parameters::Location
end
