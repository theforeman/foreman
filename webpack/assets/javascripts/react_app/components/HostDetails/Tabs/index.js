import React from 'react';
import { addGlobalFill } from '../../common/Fill/GlobalFill';
import { DEFAULT_TAB } from '../consts';
import OverviewTab from './Overview';

export const registerCoreTabs = () => {
  addGlobalFill(
    'host-details-page-tabs',
    DEFAULT_TAB,
    <OverviewTab key="host-details-overview-tab" />,
    1000
  );
};
