import { map } from 'lodash';
import { connect } from 'react-redux';
import React, { Component } from 'react';

import * as ToastActions from '../../redux/actions/toasts';

import Toast from './toastListitem/';

class ToastsList extends Component {
  render() {
    const { messages, deleteToast } = this.props;

    return (
      <div className="toast-notifications-list-pf">
        {map(messages, (toast, key) => (
          <Toast {...toast} key={key} dismiss={deleteToast.bind(this, toast.key)} />
        ))}
      </div>
    );
  }
}

const mapStateToProps = state => ({
  messages: state.toasts.messages,
});

export default connect(mapStateToProps, ToastActions)(ToastsList);
