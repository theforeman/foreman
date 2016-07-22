class BookmarkControllerValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    controllers = ["dashboard"] + (active_record_tables + Permission.resources.map {|x| x.tableize }).uniq
    record.errors[attribute] << _("%{value} is not a valid controller") % {:value => value } unless controllers.include?(value)
  end

  private

  def active_record_tables
    ActiveRecord::Base.connection.tables.map(&:to_s)
  end
end
