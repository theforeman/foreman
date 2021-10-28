import React from 'react';
import { useHistory } from 'react-router-dom';
import PropTypes from 'prop-types';

const TabsWithHashHistory = ({ tabs }) => {
  const hashHistory = useHistory();
  const onSelect = (evt, tab) => {
    hashHistory.push(`/${tab}`);
  };

  return React.cloneElement(tabs, { onSelect });
};

export default TabsWithHashHistory;

TabsWithHashHistory.propTypes = {
  tabs: PropTypes.node.isRequired,
};
