require 'test_helper'

# A deliberately large override set, well above Rack's default query-parameter limit,
# used to prove the JSON transport handles many overrides.
LARGE_OVERRIDE_COUNT = 5_000

class DummyLookupKey < LookupKey
end

class DummyLookupKeysController < LookupKeysController
  include Foreman::Controller::Parameters::LookupKey

  def self.dummy_lookup_key_params_filter
    Foreman::ParameterFilter.new(::DummyLookupKey).tap do |filter|
      add_lookup_key_params_filter(filter)
    end
  end

  def index
  end

  attr_accessor :render_real_edit

  def edit
    if params[:nested]
      render inline: <<~ERB
        <%= fields_for 'puppetclass[class_params_attributes][0]', @dummy_lookup_key do |f| %>
          <%= render 'lookup_keys/fields', f: f %>
        <% end %>
      ERB
    else
      render partial: 'lookup_keys/edit', locals: { lookup_key: resource }
    end
  end

  def process_error(hash = {})
    rendering = if render_real_edit
                  { partial: 'lookup_keys/edit', locals: { lookup_key: resource } }
                else
                  { plain: 'TaDa' }
                end
    super(hash.merge(render: rendering))
  end

  def dummy_lookup_key_params
    self.class.dummy_lookup_key_params_filter.filter_params(params, parameter_filter_context)
  end
end

Rails.application.routes.disable_clear_and_finalize = true
Rails.application.routes.draw do
  resources :dummy_lookup_keys
end
