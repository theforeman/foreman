class InterfacesController < ApplicationController
  include Foreman::Controller::Parameters::Host

  # params structure is
  #   {"host"=>
  #     {"interfaces_attributes"=>
  #       {"1405068143746"=>
  #         {"_destroy"=>"false", "type"=>"Nic::BMC", "mac"=>"", "name"=>"", "domain_id"=>"", "ip"=>""}}}}
  def new
    safe_params = host_params('host')
    @host = Host.new(safe_params)

    attributes = safe_params.fetch(:interfaces_attributes, {})
    @key, attributes = attributes.to_h.first
    raise Foreman::Exception, 'Missing attributes for interface' if @key.blank?

    if attributes.present?
      raise Foreman::Exception, 'Type was not selected' if attributes['type'].blank?

      klass = attributes.delete('type').constantize
      raise Foreman::Exception, 'Type is not Interface class' unless klass <= Nic::Base

      attributes.delete('_destroy')
      @interface = klass.new(attributes)
    end

    render 'nic/new'
  end

  def random_name
    render :json => { :name => NameGenerator.new.next_mac_name(params[:mac]) }
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'generate random name'
  end

  def action_permission
    case params[:action]
      when 'random_name'
        :edit
      else
        super
    end
  end
end
