import React from 'react';
import { translate as __ } from '../../../common/I18n';
import { addGlobalFill } from '../../common/Fill/GlobalFill';
import { DEFAULT_TAB, TABS_SLOT_ID } from '../consts';
import OverviewTab from './Overview';
import DetailTab from './Details';

export const registerCoreTabs = ({ except = [] }) => {
  addGlobalFill(
    TABS_SLOT_ID,
    DEFAULT_TAB,
    <OverviewTab key="host-details-overview-tab" />,
    5000,
    { title: __('Overview') }
  );
  addGlobalFill(
    TABS_SLOT_ID,
    'Details',
    <DetailTab key="host-details-detail-tab" />,
    4000,
    {
      title: __('Details'),
      hideTab: () => except.includes('host-details-detail-tab'),
    }
  );
};
