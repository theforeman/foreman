import React from 'react';
import Icon from './Icon';
import { ALERT_CSS } from '../../constants';

const Alert = (props) => {
  let classNames = ALERT_CSS[props.type];

  if (props.css) {
    classNames += ' ' + props.css;
  }

  if (props.dismissable) {
    classNames += ' ' + ALERT_CSS.dismissable;
  }

  const closeBtn = (
    <button className="close" data-dismiss="alert" aria-hidden="true">
      <Icon type="close" />
    </button>
  );

  return (
    <div className={classNames}>
      {props.dismissable && closeBtn}
      {props.children}
    </div>
  );
};

Alert.defaultProps = { dismissable: false, css: null, type: 'info' };
export default Alert;
