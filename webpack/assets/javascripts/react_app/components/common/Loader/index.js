import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Spinner } from 'patternfly-react';
import { STATUS } from '../../../constants';
import { deprecate } from '../../../common/DeprecationService';
import MessageBox from '../MessageBox';
import './Loader.css';

const loaderSpinner = spinnerSize => (
  <div className="loader-root">
    <Spinner loading size={spinnerSize} />
  </div>
);

const SimpleLoader = ({ spinnerSize }) => {
  useEffect(() => {
    deprecate(
      'common/Loader (patternfly-react Spinner)',
      'Spinner from @patternfly/react-core',
      '5.1'
    );
  }, []);

  return loaderSpinner(spinnerSize);
};

SimpleLoader.propTypes = {
  spinnerSize: PropTypes.string,
};

SimpleLoader.defaultProps = {
  spinnerSize: 'lg',
};

const Loader = ({ status, children, spinnerSize }) => {
  useEffect(() => {
    deprecate(
      'common/Loader (patternfly-react Spinner)',
      'Spinner from @patternfly/react-core',
      '5.1'
    );
  }, []);

  let content;

  switch (status) {
    case STATUS.PENDING: {
      return loaderSpinner(spinnerSize);
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

export const simpleLoader = spinnerSize => (
  <SimpleLoader spinnerSize={spinnerSize} />
);
