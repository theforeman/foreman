import React, { Component } from 'react';
import Toast from './Toast';
import * as ToastActions from '../../../redux/actions/toasts';
import store from '../../../redux';
import { connect } from 'react-redux';
import _ from 'lodash';

class ToastsList extends Component {

  render() {
    const { messages } = this.props;

    const visibleToasts = _.filter(messages, message => {
      return message.visible;
    });

    const markup = _.map(visibleToasts, message => {
      const dismiss = () => store.dispatch(ToastActions.hideToast(message.id));

      return <Toast {...message} key={message.id} dismiss={dismiss} />;
    });

    return (
      <div className="toast-notifications-list-pf">
        {markup}
      </div>
    );
  }
}

const mapStateToProps = state => ({
  messages: state.toasts.messages
});

export default connect(mapStateToProps, ToastActions)(ToastsList);
