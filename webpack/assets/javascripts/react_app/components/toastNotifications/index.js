import React, { Component } from 'react';
import Toast from './toastListitem/';
import * as ToastActions from '../../redux/actions/toasts';
import { connect } from 'react-redux';
import { map } from 'lodash';

class ToastsList extends Component {
  render() {
    const { messages, deleteToast } = this.props;

    return (
      <div className="toast-notifications-list-pf">
        {map(messages, (toast, key) => (
          <Toast
            {...toast}
            key={key}
            dismiss={deleteToast.bind(this, toast.key)}
          />
        ))}
      </div>
    );
  }
}

const mapStateToProps = state => ({
  messages: state.toasts.messages,
});

export default connect(mapStateToProps, ToastActions)(ToastsList);
