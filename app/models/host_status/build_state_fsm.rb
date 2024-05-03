module HostStatus

  class BuildStateFSM
    # Remove negative numbers
    TOKEN_EXPIRED = 0
    FAILED = 1
    PENDING = 2
    BUILT = 3
    HOST_UP = 4
    PROVISIONED = 5

    def initialize(current_state, global_state, states)
      @current_state = current_state
      @global_status = global_state
      @states = states
      @done = false
    end

    def transition(name)
      throw "Transition #{name} not possible!" unless @states[@current_state].follows?(name)

      begin
        @states[name].execute
        status_mapper(@states[name])
        @done = @states[name].is_final?
        @current_state = name
      rescue Exception => e
        @global_status = HostStatus::Global::ERROR
        throw "Transition #{name} failed: #{e}"
      end
    end

    private

    def status_mapper(state)
      HostStatus::Global::OK unless state.to_status < PENDING
      HostStatus::Global::ERROR
    end
  end

  class State
    def initialize(follows, side_effect, name, is_final)
      @follows = follows
      @side_effect = side_effect
      @name = name
      @is_final = is_final
    end

    def follows?(name)
      @follows.include?(name)
    end

    def execute
      @side_effect.call
    end

    def is_final?
      @is_final
    end

    def to_status
      @name
    end
  end

  fsm = BuildStateFSM.new(
    BuildStateFSM::PENDING, Global::OK,
    {
      BuildStateFSM::PENDING => State.new(
        [BuildStateFSM::FAILED, BuildStateFSM::BUILT, BuildStateFSM::TOKEN_EXPIRED],
        -> { },
        BuildStateFSM::PENDING, false),

      BuildStateFSM::BUILT => State.new(
        [BuildStateFSM::FAILED, BuildStateFSM::HOST_UP],
        -> { puts "Built" },
        BuildStateFSM::BUILT, false),

      BuildStateFSM::HOST_UP => State.new(
        [BuildStateFSM::FAILED, BuildStateFSM::PROVISIONED],
        -> { puts "Host up" },
        BuildStateFSM::HOST_UP, false),

      BuildStateFSM::PROVISIONED => State.new(
        [BuildStateFSM::FAILED], -> { puts "Provisioned" },
        BuildStateFSM::PROVISIONED, true),

      BuildStateFSM::FAILED => State.new(
        [], -> { puts "Failed" },
        BuildStateFSM::FAILED, true),

      BuildStateFSM::TOKEN_EXPIRED => State.new(
        [], -> { puts "Token expired" },
        BuildStateFSM::TOKEN_EXPIRED, true),
  })

  # fsm.transition(BuildStateFSM::BUILT)
  fsm.transition(BuildStateFSM::FAILED)
  # fsm.transition(BuildStateFSM::TOKEN_EXPIRED)
  fsm.transition(BuildStateFSM::HOST_UP)
  fsm.transition(BuildStateFSM::PROVISIONED)
end