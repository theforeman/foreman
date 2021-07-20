import React from 'react';
import { addGlobalFill } from '../../common/Fill/GlobalFill';
import OverviewTab from './Overview';
import DetailsTab from './Details';

export const registerCoreTabs = () => {
  addGlobalFill('host-details-page-tabs', 'Overview', <OverviewTab />, 1000);
  addGlobalFill('host-details-page-tabs', 'Details', <DetailsTab />, 900);
};
