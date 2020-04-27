class ReduxChannel < ApplicationCable::Channel
  def subscribed
    stream_from "redux_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
