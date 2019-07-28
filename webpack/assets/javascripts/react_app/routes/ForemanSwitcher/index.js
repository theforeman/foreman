import PropTypes from 'prop-types';
import React from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import ForemanSwitcher from './ForemanSwitcher';
import { selectRoutes } from '../RouterSelector';

const ConnectedForemanSwitcher = ({ children: coreRoutes }) => {
  const routes = useSelector(() => selectRoutes(coreRoutes), shallowEqual);

  return <ForemanSwitcher routes={routes} />;
};

ConnectedForemanSwitcher.propTypes = {
  children: PropTypes.arrayOf(PropTypes.node).isRequired,
};

export default ConnectedForemanSwitcher;
