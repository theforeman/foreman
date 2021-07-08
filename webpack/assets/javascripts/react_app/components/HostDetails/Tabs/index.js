import React from 'react';
import { addGlobalFill } from '../../common/Fill/GlobalFill';
import { DEFAULT_TAB } from '../consts';
import OverviewTab from './Overview';
import Console from './Console';
import { unregisterFillComponent } from '../../common/Fill/FillActions';

export const registerCoreTabs = () => {
  addGlobalFill(
    'host-details-page-tabs',
    DEFAULT_TAB,
    <OverviewTab key="host-details-overview-tab" />,
    1000
  );
};

export const registerConsoleTab = () => {
  addGlobalFill(
    'host-details-page-tabs',
    'Console',
    <Console key="console-tab-content" />,
    100
  );
};

export const unregisterTab = tabID => dispatch => {
  dispatch(unregisterFillComponent('host-details-page-tabs', tabID));
};
