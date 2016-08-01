import React from 'react';
import styles from './LoaderStyles';
import {STATUS} from '../../constants';
import MessageBox from './MessageBox';

const Loader = ({ status, children }) => {
let content;

  switch (status) {
    case STATUS.PENDING: {
      content = <div className="spinner spinner-lg"></div>;
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
    <div style={styles.root}>
      {content}
    </div>
  );
};

export default Loader;
