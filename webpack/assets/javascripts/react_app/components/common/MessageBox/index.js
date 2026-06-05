import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { deprecate } from '../../../common/DeprecationService';
import './MessageBox.css';

const MessageBox = ({ msg, icontype }) => {
  useEffect(() => {
    deprecate(
      'common/MessageBox',
      'EmptyState from components/common/EmptyState or @patternfly/react-core',
      '5.1'
    );
  }, []);

  return (
    <div className="message-box-root">
      <div
        className={`pficon pficon-${icontype} message-box-content message-box-icon`}
      />
      <div className="message-box-content message-box-message">{msg}</div>
    </div>
  );
};

MessageBox.propTypes = {
  icontype: PropTypes.string.isRequired,
  msg: PropTypes.string,
};

MessageBox.defaultProps = {
  msg: '',
};

export default MessageBox;
