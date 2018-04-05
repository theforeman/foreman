class ConvertReportMetricsToHash < ActiveRecord::Migration[5.1]
  def up
    eval_report_classes
    transform ActionController::Parameters, :to_h
  end

  def down
    eval_report_classes
    transform Hash, :to_params
  end

  def report_types
    execute("SELECT DISTINCT type FROM reports;").values.flatten
  end

  def report_classes
    res = report_types.map do |type|
      begin
        type.constantize
      rescue
        say "Cannot turn #{type} into a class"
        next
      end
    end
    res.compact
  end

  def eval_report_classes
    report_classes.map do |report_class|
      report_class.class_eval do
        define_method :fetch_metrics do
          self[:metrics]
        end
      end
    end
  end

  def transform(from, transform_method)
    report_classes.each do |report_class|
      report_class.unscoped.all.in_batches do |batch|
        batch.each do |report|
          metrics = report.fetch_metrics
          new_metrics = YAML.load(send(transform_method, metrics))
          new_metrics.to_unsafe_h if new_metrics.respond_to? :to_unsafe_h
          if report.metrics != new_metrics
            report.metrics = new_metrics
            report.save!
          end
        end
      end
    end
  end

  def to_h(attr)
    attr.gsub(yml_params_hash, yml_hash).gsub(yml_params_obj, yml_hash)
  end

  def to_params(attr)
    attr.gsub(yml_hash, yml_params_hash)
  end

  def yml_hash
    '!ruby/hash:ActiveSupport::HashWithIndifferentAccess'
  end

  def yml_params_hash
    '!ruby/hash:ActionController::Parameters'
  end

  def yml_params_obj
    '!ruby/object:ActionController::Parameters'
  end
end
