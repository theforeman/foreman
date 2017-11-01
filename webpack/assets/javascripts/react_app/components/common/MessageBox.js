// temporary component
// will be replaced by patternfly markup when available
import React from 'react';
import './MessageBoxStyles.css';

const MessageBox = ({ msg, icontype }) => (
  <div className="message-box-root">
    <div
      className={
        'pficon pficon-' + icontype + ' message-box-content message-box-icon'
      }
    />
    <div className="message-box-content message-box-message">{msg}</div>
  </div>
);

export default MessageBox;
