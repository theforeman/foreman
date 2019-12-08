import React from 'react';
import { useSelector } from 'react-redux';
import AppSwitcher from './AppSwitcher';
import { selectRouterLocation } from '../RouterSelector';

const connectedAppSwitcher = () => {
  const location = useSelector(selectRouterLocation);
  return <AppSwitcher location={location} />;
};

export default connectedAppSwitcher;
