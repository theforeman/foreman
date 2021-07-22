import React from 'react';
import { addGlobalFill } from '../../common/Fill/GlobalFill';
import OverviewTab from './Overview';

export const registerCoreTabs = () => {
  addGlobalFill(
    'host-details-page-tabs',
    'Overview',
    <OverviewTab key="host-details-overview-tab" />,
    1000
  );
};
