module Foreman::Controller::MemoizedResolver
  def resolver
    @resolver ||= ::MemoizedResolver.new
  end
end
