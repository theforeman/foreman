class HostAspect < ActiveRecord::Base
  attr_accessible :execution_model_type, :execution_model_id, :host_id, :aspect_subject, :execution_model_attributes

  belongs_to_host :inverse_of => :host_aspects
  belongs_to :execution_model, :polymorphic => true, :autosave => false
  accepts_nested_attributes_for :execution_model

  def populate_fields_from_facts(importer, type)
    execution_model.populate_fields_from_facts(importer, type) if execution_model.respond_to? :populate_fields_from_facts
  end

  def info
    execution_model.info if execution_model.respond_to? :info
  end

  def smart_proxy_ids
    execution_model.smart_proxy_ids if execution_model.respond_to? :smart_proxy_ids
  end

  def after_clone
    execution_model.after_clone if execution_model.respond_to? :after_clone
  end

  def template_filter_options(kind)
    execution_model.template_filter_options(kind) if execution_model.respond_to? :template_filter_options
  end
end