module HasManyCommon
  extend ActiveSupport::Concern

  def assoc_klass(association)
    self.class.reflect_on_association(association).klass
  end

  # calls method :name or whatever is defined in attr_name :title
  def name_method
    send(self.class.attribute_name).to_s
  end

  module ClassMethods
    # default attribute used by *_names and *_name is :name
    # if :name doesn't exist, :id as a string is used, so it doesn't error out
    # if attr_name :field is not defined most likely model will have attr_name
    # :field to overwrite attribute_name
    def attribute_name
      if has_name?
        :name
      else
        :id
      end
    end

    def has_name?(field = "name")
      column_names.include?(field)
    end

    # class method in model to overwrite default attribute_name
    # Ex.
    # Class Hostgroup
    #   attr_name :title
    def attr_name(attribute)
      self_class.send(:define_method, "attribute_name") do
        attribute
      end
    end

    def self_class
      class << self; self end
    end

    #### has_many ####
    def has_many(name, scope = nil, **kwargs, &extension)
      has_many_names_for(name)
      super
    end

    def has_and_belongs_to_many(name, scope = nil, **kwargs, &extension)
      has_many_names_for(name)
      super
    end

    def has_many_names_for(association)
      assoc = association.to_s.tableize.singularize

      # SETTER _names= method
      define_method "#{assoc}_names=" do |name_values|
        ids = Array.wrap(name_values).map do |name_value|
          assoc_klass(association).send("find_by_#{assoc_klass(association).attribute_name}", name_value).id
        end
        send("#{assoc}_ids=", ids)
      end

      # GETTER _names method
      define_method "#{assoc}_names" do
        send(association).map(&:name_method)
      end
    end

    #### belongs_to ####
    def belongs_to(name, scope = nil, name_accessor: nil, **kwargs)
      belongs_to_name_for(name, name_accessor)
      super(name, scope, **kwargs)
    end

    def belongs_to_name_for(association, name_accessor)
      assoc = association.to_s.tableize.singularize
      assoc_name = name_accessor || "#{assoc}_name"

      # SETTER _name= method
      define_method "#{assoc_name}=" do |name_value|
        assoc_id = assoc_klass(association).send("find_by_#{assoc_klass(association).attribute_name}", name_value).try(:id)
        unless assoc_id
          raise Foreman::AssociationNotFound
                  .new(_("Could not find %{association} with name: %{name}") % { name: name_value, association: association })
        end
        send("#{assoc}_id=", assoc_id)
      end

      # GETTER _name method
      define_method assoc_name do
        send(association).try(:name_method)
      end
    end
  end
end
