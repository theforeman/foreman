import React from 'react';
import {STATUS} from '../../constants';
import MessageBox from './MessageBox';
import './LoaderStyles.css';

const Loader = ({ status, children, spinnerSize = 'lg' }) => {
let content;

  switch (status) {
    case STATUS.PENDING: {
      content = <div className={'spinner spinner-' + spinnerSize}></div>;
      break;
    }
    case STATUS.RESOLVED: {
      content = children[0];
      break;
    }
    case STATUS.ERROR: {
      content = children[1];
      break;
    }
    default:
      content = (<MessageBox icontype="error-circle-o" msg="Invalid Status" />);
      break;
  }

  return (
    <div className="loader-root">
      {content}
    </div>
  );
};

export default Loader;
