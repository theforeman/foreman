import React from 'react';
import helpers from '../../../common/helpers';
import Timer from '../../../common/Timer';
import Alert from '../../common/Alert';
import PropTypes from 'prop-types';
import { defaultTimerDelay } from './Toast.consts';

import './Toast.scss';
class Toast extends React.Component {
  constructor(props) {
    super(props);
    helpers.bindMethods(this, ['onMouseEnter', 'onMouseLeave']);
  }

  componentDidMount() {
    const { sticky, dismiss, timerDelay } = this.props;

    if (!sticky) {
      this.timer = new Timer(dismiss, timerDelay || defaultTimerDelay);
      this.timer.startTimer();
    }
  }

  componentWillUnmount() {
    this.timer && this.timer.clearTimer();
  }

  onMouseEnter() {
    this.timer && this.timer.clearTimer();
  }

  onMouseLeave() {
    this.timer && this.timer.startTimer();
  }

  render() {
    const { type, link, message, dismiss } = this.props;

    return (
      <Alert
        type={type}
        className="toast-pf"
        onClose={dismiss}
        onMouseEnter={this.onMouseEnter}
        onMouseLeave={this.onMouseLeave}
        link={link}
        message={message}
      />
    );
  }
}
Toast.propTypes = {
  message: PropTypes.string.isRequired,
};

export default Toast;
