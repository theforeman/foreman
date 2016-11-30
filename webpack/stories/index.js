import React from 'react';

/* eslint-disable no-unused-vars */
import { storiesOf, action, linkTo, addDecorator } from '@kadira/storybook';
require('../assets/javascripts/bundle');
require('../../app/assets/javascripts/application');
import StatisticsChartsList from
'../assets/javascripts/react_app/components/charts/StatisticsChartsList';
import StatisticsChartBox from
'../assets/javascripts/react_app/components/charts/StatisticsChartBox';
import PowerStatus from
'../assets/javascripts/react_app/components/hosts/PowerStatus';

addDecorator((story) => (
  <div className="ca" style={{textAlign: 'center'}}>
    {story()}
    <div id="targetChart"></div>
  </div>
));

storiesOf('Statistics', module)
  .add('Loading', () => (
    <StatisticsChartBox
      config={{data: {columns: [] }}}
      noDataMsg={'No data here'}
      title="Title"
      status="PENDING" />
  ))
    .add('Without Data', () => (
    <StatisticsChartBox
      config={{data: {columns: [] }}}
      noDataMsg={'No data here'}
      title="Title"
      status="RESOLVED" />
  ))
    .add('With Error', () => (
    <StatisticsChartBox
      config={{data: {columns: [] }}}
      title="Title"
      noDataMsg={'No data here'}
      errorText="Ooops"
      status="ERROR" />
  ))
  .add('With data', () => (
    <StatisticsChartBox
      config={{data: {columns: [1, 2]}}}
      modalConfig={{}}
      noDataMsg={'No data here'}
      id="target"
      status="RESOLVED"
    />
  )
);

storiesOf('Power Status', module)
  .add('Loading', () => (
    <PowerStatus
      loadingStatus="PENDING"
    />
  ))
  .add('ON', () => (
    <PowerStatus
      state="on"
      title="on"
      loadingStatus="RESOLVED"
      statusText="On"
    />
  ))
  .add('OFF', () => (
    <PowerStatus
      state="off"
      title="off"
      loadingStatus="RESOLVED"
      statusText="Off"
    />
  ))
  .add('N/A', () => (
    <PowerStatus
      state="na"
      statusText="No power support"
      loadingStatus="RESOLVED"
      title="N/A"
    />
  ))
    .add('Error', () => (
    <PowerStatus
      state="na"
      statusText="Exception error some where"
      loadingStatus="ERROR"
      title="N/A"
    />
  )
);
