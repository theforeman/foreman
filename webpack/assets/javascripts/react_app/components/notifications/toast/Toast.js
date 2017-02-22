import React from 'react';
import Icon from '../../common/Icon';
import Alert from '../../common/Alert';

const Toast = (props) => {
  return (
    <Alert
      type={props.type}
      dismissable={props.close}
      css="toast-pf"
      >
      <div className="pull-right toast-pf-action">
        <a href="#">
          {props.link}
        </a>
      </div>
      <Icon type={props.type}/>
      <strong>
        {props.title}
      </strong>
      {props.message}
    </Alert>
  );
};

Toast.defaultProps = { close: true, type: 'success' };

export default Toast;
