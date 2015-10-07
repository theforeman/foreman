module HostAspects
  class Configuration
    SUBJECTS = [:configuration]

    SUBJECTS.each do |subject|
      define_method "register_#{subject}" do |aspect_name, aspect_model = nil, &block|
        register(subject, aspect_name, aspect_model, &block)
      end
    end

    SUBJECTS.each do |subject|
      define_method "#{subject}_aspect" do
        aspects_registry[aspect_subjects[subject]]
      end
    end

    def registered_aspects
      aspects_registry.dup
    end

    def [](subject)
      aspects_registry[aspect_subjects[subject]]
    end

    private

    attr_writer :aspects_registry
    attr_writer :aspect_subjects

    def aspects_registry
      @aspects_registry ||= {}
    end

    def aspect_subjects
      @aspect_subjects ||= {}
    end

    def register(subject, aspect_name, aspect_model = nil, &block)
      if old_subj = aspect_subjects[subject]
        throw "Could not register #{aspect_name}, #{old_subj} is already registered as #{subject} aspect."
      end

      entry = Entry.new(aspect_name, aspect_model, subject)

      entry.instance_eval(&block) if block_given?

      aspects_registry[entry.name] = entry
      aspect_subjects[subject] = entry.name
    end
  end
end