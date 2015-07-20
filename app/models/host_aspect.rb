class HostAspect < ActiveRecord::Base
  attr_accessible :execution_model_type, :execution_model_id, :host_id, :aspect_type, :execution_model_attributes

  belongs_to_host :inverse_of => :host_aspects
  belongs_to :execution_model, :polymorphic => true
  accepts_nested_attributes_for :execution_model

  def populate_fields_from_facts(importer, type, proxy_id = nil)
    execution_model.populate_fields_from_facts(importer, type, proxy_id) if execution_model.respond_to? :populate_fields_from_facts
  end

  def info
    execution_model.info if execution_model.respond_to? :info
  end

  def smart_proxy_ids
    execution_model.smart_proxy_ids if execution_model.respond_to? :smart_proxy_ids
  end

  # This method will be used when creating aspect class via the standard host_aspects table, and not directly via its property on host
  def build_execution_model(params, assignment_options)
    executer_type = self.execution_model_type.constantize
    model = executer_type.new(params)
    self.execution_model = model
    model.reflections.each_pair do |k, v|
      if v.options[:inverse_of] == :execution_model
        model.send("#{k}=", self)
      end
    end
  end
end
