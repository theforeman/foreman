module HostAspects
  class << self
    SUBJECTS = [:configuration]

    SUBJECTS.each do |subject|
      define_method "register_#{subject}".to_sym do |aspect_name, aspect_model = nil, &block|
        self.send('register', subject, aspect_name, aspect_model, &block)
      end
    end

    SUBJECTS.each do |subject|
      define_method "#{subject}_aspect".to_sym do
        @aspects_registry[@aspect_subjects[subject]]
      end
    end

    def registry
      @aspects_registry
    end

    private

    def register(subject, aspect_name, aspect_model = nil, &block)
      @aspects_registry ||= {}
      @aspect_subjects ||= {}

      if old_subj = @aspect_subjects[subject]
        throw "Could not register #{aspect_name}, #{old_subj} is already registered as #{subject} aspect."
      end

      entry = Entry.new(aspect_name, aspect_model, subject)

      entry.instance_eval(&block) if block_given?

      @aspects_registry[entry.name] = entry
      @aspect_subjects[subject] = entry.name
    end
  end

  class Entry
    ATTRIBUTES = [:name, :model, :helper, :extension]
    attr_accessor(*ATTRIBUTES)

    attr_accessor :subject

    ATTRIBUTES.each do |attr|
      define_method "#{attr}_class".to_sym do
        sym = self.send(attr)
        to_class(sym)
      end
    end

    def initialize(aspect_name, aspect_model, aspect_subject)
      self.name = to_name(aspect_name)
      self.model = to_model(aspect_model)
      self.subject = aspect_subject
    end

    def add_helper(aspect_helper)
      self.helper = aspect_helper.try(:to_sym)
    end

    def extend_model(extension_symbol)
      self.extension = extension_symbol.to_sym
    end

    private

    def to_name(aspect_name)
      aspect_name.to_sym
    end

    def to_model(aspect_model)
      aspect_model.try(:to_sym) || self.name.to_sym
    end

    private

    def to_class(symbol)
      symbol.to_s.camelize.constantize if symbol
    end
  end
end