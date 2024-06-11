module BuildStateFSM
  class FSM
    # Remove negative numbers
    DORMANT = 4
    PENDING = 1
    BUILT = 0
    HOST_UP = 5
    PROVISIONED = 6
    CANCELED = 7

    TOKEN_EXPIRED = 2
    FAILED = 3

    def initialize(current_state, global_state, states)
      @current_state = current_state
      @global_status = global_state
      @states = states
      @done = false
    end

    def transition(name, arguments = {})
      throw "Transition #{name} not possible!" unless @states[@current_state].follows?(name)

      begin
        @states[name].execute(arguments)
        status_mapper(@states[name])
        @done = @states[name].is_final?
        @current_state = name
      rescue Exception => e
        @global_status = HostStatus::Global::ERROR
        throw "Transition #{name} failed: #{e}"
      end
    end

    def current_state
      @current_state.to_status
    end

    def global_state
      @global_status
    end

    private

    def status_mapper(state)
      HostStatus::Global::OK unless state.to_status < PENDING
      HostStatus::Global::ERROR
    end
  end

  class State
    def initialize(follows, side_effect, name, is_final = false)
      @follows = follows
      @side_effect = side_effect
      @name = name
      @is_final = is_final
    end

    def follows?(name)
      @follows.include?(name)
    end

    def execute(trailing_call)
      @side_effect.call
      trailing_call.call
    end

    def is_final?
      @is_final
    end

    def to_status
      @name
    end
  end
end