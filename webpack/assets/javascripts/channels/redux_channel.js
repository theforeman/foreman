import store from '../react_app/redux';
import consumer from './consumer';

consumer.subscriptions.create('ReduxChannel', {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received({ action }) {
    store.dispatch(action);
  },
});
