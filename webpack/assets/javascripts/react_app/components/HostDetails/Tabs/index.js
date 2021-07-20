import React from 'react';
import { addGlobalFill } from '../../common/Fill/GlobalFill';
import DetailsTab from './Details';
import Console from './Console';

export const registerCoreTabs = () => {
  addGlobalFill(
    'host-details-page-tabs',
    'Overview',
    <DetailsTab key="details-tab-content" />,
    1000
  );
  addGlobalFill(
    'host-details-page-tabs',
    'Console',
    <Console key="console-tab-content" />,
    100
  );
};
