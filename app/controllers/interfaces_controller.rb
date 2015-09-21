class InterfacesController < ApplicationController
  # params structure is
  #   {"host"=>
  #     {"interfaces_attributes"=>
  #       {"1405068143746"=>
  #         {"_destroy"=>"false", "type"=>"Nic::BMC", "mac"=>"", "name"=>"", "domain_id"=>"", "ip"=>""}}}}
  def new
    @host = Host.new params[:host]

    attributes = params[:host].fetch(:interfaces_attributes, {})
    @key, attributes = attributes.first
    raise Foreman::Exception, 'Missing attributes for interface' if @key.blank?

    if attributes.present?
      raise Foreman::Exception, 'Type was not selected' if attributes[:type].blank?

      klass = attributes.delete(:type).constantize
      raise Foreman::Exception, 'Type is not Interface class' unless klass <= Nic::Base

      attributes.delete(:_destroy)
      @interface = klass.new(attributes)
    end

    render 'nic/new'
  end
end
