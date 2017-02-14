import React from 'react';
import Icon from '../../common/Icon';
import helpers from '../../../common/helpers';
import { ALERT_CSS } from '../../../constants';
import CloseButton from '../../common/CloseButton';
// eslint-disable-next-line no-unused-vars
import Timer from '../../../common/Timer';

class Toast extends React.Component {
  constructor(props) {
    super(props);
    helpers.bindMethods(this, ['dismiss', 'execute', 'onMouseEnter', 'onMouseLeave']);
  }

  componentDidMount() {
    const { sticky, timerDelay } = this.props;

    if (!sticky) {
      this.timer = new Timer(this.execute, timerDelay);
      this.timer.startTimer();
    }
  }

  componentWillUnmount() {
    if (this.timer) {
      this.timer.clearTimer();
      this.timer = null;
    }
  }

  dismiss() {
    this.props.dismiss();
  }

  execute() {
    if (this.timer) {
      this.timer.clearTimer();
      this.timer = null;
    }
    this.dismiss();
  }

  onMouseEnter() {
    if (this.timer) {
      this.timer.clearTimer();
    }
  }

  onMouseLeave() {
    if (this.timer) {
      this.timer.startTimer();
    }
  }

  render() {
    const { type, dismissable, link, message } = this.props;

    return (
      <div className={ALERT_CSS[type] + ' toast-pf'}
           onMouseEnter={this.onMouseEnter} onMouseLeave={this.onMouseLeave} >
        {dismissable && <CloseButton onClick={this.dismiss}></CloseButton>}

        <div className="pull-right toast-pf-action">
          <a href="#">
            {link}
          </a>
        </div>
        <Icon type={type}/>
        {message}
      </div>
    );
  }
}
Toast.propTypes = {
  message: React.PropTypes.string.isRequired
};

Toast.defaultProps = {
  dismissable: true,
  visible: true,
  type: 'success',
  timerDelay: 8000
};

export default Toast;
