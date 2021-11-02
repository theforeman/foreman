import React from 'react';
import { useHistory } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { push } from 'connected-react-router';
import PropTypes from 'prop-types';

const TabsWithHashHistory = ({ tabs }) => {
  const hashHistory = useHistory();
  const dispatch = useDispatch();
  const onSelect = (evt, tab) => {
    const hash = `/${tab}`;
    hashHistory.push(hash);
    dispatch(push({ search: null, hash })); // A tab component may update the url with search params which we need to clear when switching between tabs.
  };

  return React.cloneElement(tabs, { onSelect });
};

export default TabsWithHashHistory;

TabsWithHashHistory.propTypes = {
  tabs: PropTypes.node.isRequired,
};
