import React from 'react';
import MessageBox from '../common/MessageBox';

const Chart = ({ cssClass, id, hasData, noDataMsg, style }) => {
  const msg = noDataMsg || 'No data available';

  return hasData ?
    <div className={cssClass} id={id + 'Chart'}></div> :
    (
      <MessageBox msg={msg} icontype="info"></MessageBox>
    );
};

export default Chart;
