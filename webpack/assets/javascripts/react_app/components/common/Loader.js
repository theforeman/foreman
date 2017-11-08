import React from 'react';
import { STATUS } from '../../constants';
import MessageBox from './MessageBox';
import './LoaderStyles.css';

const _simpleLoader = spinnerSize => (
  <div className="loader-root">
    <div className={`spinner spinner-${spinnerSize}`} />
  </div>
);

const Loader = ({ status, children, spinnerSize = 'lg' }) => {
  let content;

  switch (status) {
    case STATUS.PENDING: {
      return _simpleLoader(spinnerSize);
    }
    case STATUS.RESOLVED: {
      // eslint-disable-next-line prefer-destructuring
      content = children[0];
      break;
    }
    case STATUS.ERROR: {
      // eslint-disable-next-line prefer-destructuring
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

export const simpleLoader = _simpleLoader;
