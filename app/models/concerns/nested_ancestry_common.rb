module NestedAncestryCommon
  extend ActiveSupport::Concern

  included do
    before_save :set_label, :on => [:create, :update, :destroy]
    after_save :set_other_labels, :on => [:update, :destroy]
    after_save :update_matchers , :on => :update, :if => Proc.new {|obj| obj.label_changed?}

    scoped_search :on => :label, :complete_value => :true, :default_order => true
  end

  def get_label
    return name if ancestry.empty?
    ancestors.map { |a| a.name + '/' }.join + name
  end

  private

  def set_label
    self.label = get_label if (name_changed? || ancestry_changed? || label.blank?)
  end

  def set_other_labels
    if name_changed? || ancestry_changed?
      self.class.where('ancestry IS NOT NULL').each do |obj|
        if obj.path_ids.include?(self.id)
          obj.update_attributes(:label => obj.get_label)
        end
      end
    end
  end

  def obj_type
    self.class.to_s.downcase
  end

  def update_matchers
    lookup_values = LookupValue.where(:match => "#{obj_type}=#{label_was}")
    lookup_values.update_all(:match => "#{obj_type}=#{label}")
  end

end
