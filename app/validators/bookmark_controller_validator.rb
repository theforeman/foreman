class BookmarkControllerValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless self.class.valid_controllers_list.include?(value)
      record.errors[attribute] << _("%{value} is not a valid controller") % {:value => value }
    end
  end

  def self.valid_controllers_list
    @valid_controllers_list ||= (["dashboard", "common_parameters"] +
      ActiveRecord::Base.connection.tables.map(&:to_s) +
      Permission.resources.map(&:tableize)).uniq
  end

  def self.reset_controllers_list
    @valid_controllers_list = nil
  end
end
