import React from 'react';

import { storiesOf } from '@storybook/react';
import { action } from '@storybook/addon-actions';

import ChartBox from '../assets/javascripts/react_app/components/statistics/ChartBox';
import PieChart from '../assets/javascripts/react_app/components/common/charts/PieChart';
import mockData from './data/charts/donutChartMockData';
import PowerStatusInner from '../assets/javascripts/react_app/components/hosts/powerStatus/powerStatusInner';
import Store from '../assets/javascripts/react_app/redux';
import Toast from '../assets/javascripts/react_app/components/toastNotifications/toastListitem';
import StorageContainer from '../assets/javascripts/react_app/components/hosts/storage/vmware';
import * as VMWareData from './data/storage/vmware';

require('../assets/javascripts/bundle');
require('../../app/assets/javascripts/application');
require('../../app/assets/stylesheets/base.scss');

storiesOf('Charts', module)
  .add('Loading', () => (
    <ChartBox
      chart={{ data: [] }}
      noDataMsg="No data here"
      title="Title"
      status="PENDING"
    />
  ))
  .add('Without Data', () => (
    <ChartBox
      chart={{ data: [] }}
      noDataMsg="No data here"
      title="Title"
      status="RESOLVED"
    />
  ))
  .add('With Error', () => (
    <ChartBox
      chart={{ data: [] }}
      title="Title"
      noDataMsg="No data here"
      errorText="Ooops"
      status="ERROR"
    />
  ))
  .add('With Data + Modal', () => (
    <ChartBox
      chart={{ data: mockData.config.data.columns }}
      noDataMsg={mockData.noDataMsg}
      tip={mockData.tip}
      title={mockData.title}
      status="RESOLVED"
    />
  ))
  .add('Donut Chart', () => (
    <PieChart onclick={action('clicked')} data={mockData.config.data.columns} />
  ));

storiesOf('Power Status', module)
  .add('Loading', () => <PowerStatusInner />)
  .add('ON', () => <PowerStatusInner state="on" title="on" statusText="On" />)
  .add('OFF', () => (
    <PowerStatusInner state="off" title="off" statusText="Off" />
  ))
  .add('N/A', () => (
    <PowerStatusInner state="na" statusText="No power support" title="N/A" />
  ))
  .add('Error', () => (
    <PowerStatusInner
      state="na"
      statusText="Exception error some where"
      error="someError"
      title="N/A"
    />
  ));

function getDismiss() {
  return action('dismiss alert');
}

storiesOf('Notifications', module)
  .add('Error', () => (
    <Toast
      message="Please don't do that again"
      type="error"
      dismiss={getDismiss()}
    />
  ))
  .add('Oops - no close', () => (
    <Toast
      message="Please don't do that again"
      type="error"
      dismissable={false}
      sticky
    />
  ))
  .add('Success with link', () => (
    <Toast
      message="Payment received"
      type="success"
      link={{ title: 'click for details', href: 'google.com' }}
      dismiss={getDismiss()}
    />
  ))
  .add('Warning', () => (
    <Toast
      message="I'm not sure you should do that"
      type="warning"
      dismiss={getDismiss()}
    />
  ))
  .add('Short life', () => (
    <Toast
      message="I'm about to expire"
      type="warning"
      dismiss={getDismiss()}
    />
  ))
  .add('Sticky', () => (
    <Toast
      message="I'm Going to stick around"
      type="warning"
      sticky
      dismiss={getDismiss()}
    />
  ));

storiesOf('Host VMWare Storage', module)
  .add('default state for new host', () => (
    <StorageContainer store={Store} data={VMWareData.state1} />
  ))
  .add('multiple controllers', () => (
    <StorageContainer store={Store} data={VMWareData.state2} />
  ))
  .add('on clone', () => (
    <StorageContainer store={Store} data={VMWareData.clone} />
  ))
  .add('without any controllers', () => (
    <StorageContainer store={Store} data={VMWareData.emptyState} />
  ));
