import React from 'react';
import { translate as __ } from '../../../common/I18n';
import { addGlobalFill } from '../../common/Fill/GlobalFill';
import { DEFAULT_TAB, TABS_SLOT_ID } from '../consts';
import OverviewTab from './Overview';
import DetailTab from './Details';
import ReportsTab from './ReportsTab';
import ParametersTab from './Parameters';

const TAB_WEIGHT_OVERVIEW = 5000;
const TAB_WEIGHT_DETAILS = 4000;
const TAB_WEIGHT_PARAMETERS = 850;
const TAB_WEIGHT_REPORTS = 477;

export const registerCoreTabs = () => {
  addGlobalFill(
    TABS_SLOT_ID,
    DEFAULT_TAB,
    <OverviewTab key="host-details-overview-tab" />,
    TAB_WEIGHT_OVERVIEW,
    { title: __('Overview') }
  );
  addGlobalFill(
    TABS_SLOT_ID,
    'Details',
    <DetailTab key="host-details-detail-tab" />,
    TAB_WEIGHT_DETAILS,
    { title: __('Details') }
  );
  addGlobalFill(
    TABS_SLOT_ID,
    'Reports',
    <ReportsTab key="host-details-reports-tab" />,
    TAB_WEIGHT_REPORTS,
    {
      title: __('Reports'),
    }
  );
  addGlobalFill(
    TABS_SLOT_ID,
    'Parameters',
    <ParametersTab key="host-details-parameters-tab" />,
    TAB_WEIGHT_PARAMETERS,
    {
      title: __('Parameters'),
    }
  );
};
