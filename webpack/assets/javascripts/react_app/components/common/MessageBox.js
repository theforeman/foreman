// temporary component
// will be replaced by patternfly markup when available
import React from 'react';
import styles from './MessageBoxStyles';

const MessageBox = ({ msg, icontype, style }) =>
(
    <div style={{ ...styles.root, ...style }}>
      <div className={'pficon pficon-' + icontype}
           style={{ ...styles.content, ...styles.icon }}></div>
      <div style={{ ...styles.content, ...styles.message }}>{msg}</div>
    </div>
  );

export default MessageBox;

