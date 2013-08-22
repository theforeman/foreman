module HasManyCommon
  extend ActiveSupport::Concern

  def assoc_klass(association)
    association.to_s.classify.constantize
  end

  # calls method :name or whatever is defined in attr_name :label
  def name_method
    send(self.class.attribute_name)
  end

  module ClassMethods

    # default is :name if model has name, otherwise, use :id so it doesn't error
    # most likely model will have attr_name :field to overwrite this
    def attribute_name
      if has_name?
        :name
      else
        :id
      end
    end

    def has_name?(field="name")
      self.column_names.include?(field)
    end

    # default attribute used by *_names and *_name is :name
    # Model class can call this class method to override attribute_name
    # Ex.
    # Class Hostgroup
    #   attr_name :label
    #
    def attr_name(attribute)
      define_singleton_method "attribute_name" do
        attribute
      end
    end

    #### has_many ####
    def has_many(association, options = {})
      has_many_names_for(association, options)
      super
    end

    def has_and_belongs_to_many(association, options = {})
      has_many_names_for(association, options)
      super
    end

    def has_many_names_for(association, options)
      assoc = association.to_s.tableize.singularize

      # SETTER _names= method
      define_method "#{assoc}_names=" do |name_values|
        ids = Array.wrap(name_values).map do |name_value|
          assoc_klass(association).send("find_by_#{assoc_klass(association).attribute_name}", name_value).id
        end
        self.send("#{assoc}_ids=", ids)
      end

      # GETTER _names method
      define_method "#{assoc}_names" do
        assoc_klass(association).where(:id => send("#{assoc}_ids")).map { |res| res.name_method }
      end
    end

    #### belongs_to ####
    def belongs_to(association, options = {})
      belongs_to_name_for(association, options)
      super
    end

    def has_and_belongs_to_many(association, options = {})
      belongs_to_name_for(association, options)
      super
    end

    def belongs_to_name_for(association, options)
      assoc = association.to_s.tableize.singularize

      # SETTER _name= method
      define_method "#{assoc}_name=" do |name_value|
        assoc_id = assoc_klass(association).send("find_by_#{assoc_klass(association).attribute_name}", name_value).id
        self.send("#{assoc}_id=", assoc_id)
      end

      # GETTER _name method
      define_method "#{assoc}_name" do
        assoc_id = self.send("#{assoc}_id")
        assoc_klass(association).find_by_id(assoc_id).try(:name_method)
      end
    end

  end

end
