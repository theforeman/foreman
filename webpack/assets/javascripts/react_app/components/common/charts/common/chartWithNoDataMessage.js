import React from 'react';
import MessageBox from '../../MessageBox';

export const chartWithNoDataMessage = (WrappedComp, noDataMsg = 'No data available') => (props) => {
  const columns = props && props.data && props.data.columns ? props.data.columns : [];
  if (columns.length > 0) {
    return (<WrappedComp {...props} />);
  }
  return <MessageBox msg={noDataMsg} icontype="info" />;
};
