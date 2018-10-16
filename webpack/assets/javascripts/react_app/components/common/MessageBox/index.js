// temporary component
// will be replaced by patternfly markup when available
// temporary component
// will be replaced by patternfly markup when available
import React from 'react';
import PropTypes from 'prop-types';
import './MessageBox.css';

const MessageBox = ({ msg, icontype }) => (
  <div className="message-box-root">
    <div
      className={`pficon pficon-${icontype} message-box-content message-box-icon`}
    />
    <div className="message-box-content message-box-message">{msg}</div>
  </div>
);

MessageBox.propTypes = {
  msg: PropTypes.string.isRequired,
  icontype: PropTypes.string.isRequired,
};

export default MessageBox;
