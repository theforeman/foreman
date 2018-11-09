import React from 'react';
import PropTypes from 'prop-types';
import { Spinner } from 'patternfly-react';
import { STATUS } from '../../../constants';
import MessageBox from '../MessageBox';
import './Loader.css';

const _simpleLoader = spinnerSize => (
  <div className="loader-root">
    <Spinner loading size={spinnerSize} />
  </div>
);

const Loader = ({ status, children, spinnerSize }) => {
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
      content = <MessageBox icontype="error-circle-o" msg="Invalid Status" />;
      break;
  }

  return <div className="loader-root">{content}</div>;
};

Loader.propTypes = {
  children: PropTypes.array,
  status: PropTypes.string,
  spinnerSize: PropTypes.string,
};

Loader.defaultProps = {
  children: ['', ''],
  status: '',
  spinnerSize: 'lg',
};

export default Loader;

export const simpleLoader = _simpleLoader;
