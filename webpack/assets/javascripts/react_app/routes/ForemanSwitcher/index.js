import PropTypes from 'prop-types';
import React from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import { Routes, Route } from 'react-router-dom';

import { fallbackRoute } from '../RoutingService';
import { selectRoutes } from '../RouterSelector';

const FallbackRoute = () => {
  React.useEffect(() => {
    fallbackRoute();
  }, []);

  return null;
};

const ForemanSwitcher = ({ children: coreRoutes }) => {
  const routes = useSelector(() => selectRoutes(coreRoutes), shallowEqual);

  return (
    <Routes>
      {routes}
      <Route path="*" element={<FallbackRoute />} />
    </Routes>
  );
};

ForemanSwitcher.propTypes = {
  children: PropTypes.arrayOf(PropTypes.node).isRequired,
};

export default ForemanSwitcher;
