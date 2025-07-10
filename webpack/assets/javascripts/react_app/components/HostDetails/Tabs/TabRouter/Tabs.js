import React from 'react';
import { useNavigate } from 'react-router-dom';
import PropTypes from 'prop-types';

const TabsWithHashHistory = ({ tabs }) => {
  const navigate = useNavigate(); 

  const onSelect = (evt, tab) => {
    navigate(`/${tab}`); 
  };

  return React.cloneElement(tabs, { onSelect });
};

TabsWithHashHistory.propTypes = {
  tabs: PropTypes.node.isRequired,
};

export default TabsWithHashHistory;
