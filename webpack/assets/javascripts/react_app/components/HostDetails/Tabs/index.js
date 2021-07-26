import React from 'react';
import { translate as __ } from '../../../common/I18n';
import { addGlobalFill } from '../../common/Fill/GlobalFill';
import { DEFAULT_TAB, TABS_SLOT_ID } from '../consts';
import OverviewTab from './Overview';

export const registerCoreTabs = () => {
  addGlobalFill(
    TABS_SLOT_ID,
    DEFAULT_TAB,
    <OverviewTab key="host-details-overview-tab" />,
    1000,
    { title: __('Overview') }
  );
};
