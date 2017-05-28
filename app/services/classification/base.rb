module Classification
  class Base
    delegate :hostgroup, :environment_id, :puppetclass_ids, :classes,
             :to => :host

    def initialize(args = {})
      @host = args[:host]
      @safe_render = SafeRender.new(:variables => {:host => host})
    end

    #override to return the relevant enc data and format
    def enc
      raise NotImplementedError
    end

    def inherited_values
      keys.inherited_values(@host).raw
    end

    protected

    attr_reader :host

    #override this method to return the relevant parameters for a given set of classes
    def class_parameters
      keys
    end

    def keys
      raise NotImplementedError
    end

    def values_hash
      keys.values_hash(@host).raw
    end
  end
end
