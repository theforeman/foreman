import consumer from './actionCableConsumer';

// Export a function to subscribe with custom callbacks
export const subscribeToNotifications = (callbacks = {}) =>
  consumer.subscriptions.create(
    { channel: 'NotificationChannel' },
    {
      connected() {
        if (callbacks.connected) callbacks.connected();
      },
      disconnected() {
        if (callbacks.disconnected) callbacks.disconnected();
      },
      received(data) {
        if (callbacks.received) callbacks.received(data);
      },
    }
  );
