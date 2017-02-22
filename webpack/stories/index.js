import React from 'react';

/* eslint-disable no-unused-vars */
import { storiesOf, action, linkTo, addDecorator } from '@kadira/storybook';
require('../assets/javascripts/bundle');
require('../../app/assets/javascripts/application');
import ChartBox from
  '../assets/javascripts/react_app/components/charts/ChartBox';
import ChartModal from '../assets/javascripts/react_app/components/charts/ChartModal';
import chartService from '../assets/javascripts/services/statisticsChartService';
import mockData from './data/charts/donutChartMockData';
import PowerStatus from
  '../assets/javascripts/react_app/components/hosts/PowerStatus';
import Toast from '../assets/javascripts/react_app/components/notifications/toast/Toast';
import Alert from '../assets/javascripts/react_app/components/common/Alert';
import Fade from '../assets/javascripts/react_app/components/common/Fade';

addDecorator((story) => (
  <div className="ca" style={{ textAlign: 'center' }}>
    {story()}
    <div id="targetChart"></div>
  </div>
));

storiesOf('Charts', module)
  .add('Loading', () => (
    <ChartBox
      config={{ data: { columns: [] } }}
      noDataMsg={'No data here'}
      title="Title"
      status="PENDING"/>
  ))
  .add('Without Data', () => (
    <ChartBox
      config={{ data: { columns: [] } }}
      noDataMsg={'No data here'}
      title="Title"
      status="RESOLVED"/>
  ))
  .add('With Error', () => (
    <ChartBox
      config={{ data: { columns: [] } }}
      title="Title"
      noDataMsg={'No data here'}
      errorText="Ooops"
      status="ERROR"/>
  ))
  .add('Donut Chart', () => (
    <ChartBox
      config={mockData.config}
      modalConfig={mockData.modalConfig}
      noDataMsg={mockData.noDataMsg}
      tip={mockData.tip}
      id={mockData.id}
      title={mockData.title}
      status="RESOLVED"
    />
  ))
  .add('Modal', () => {
    /*
     onHide={this.closeModal}
     onEnter={this.onEnter}
     */
    let show = true;

    function hide() {
      show = false;
    }

    return (
      <ChartModal
        show={show}
        onHide={hide}
        config={mockData.modalConfig}
        title={mockData.title}
        id={mockData + 'Modal'}
        setTitle={chartService.setTitle}
      />
    );
  });

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

storiesOf('Notifications', module)
  .add('Success State', () => (
    <Toast title="Great Succees!" />
  ))
  .add('Error', () => (
    <Toast message="Please don't do that again" type="error"/>
  ))
  .add('Oops - no close', () => (
    <Toast message="Please don't do that again" type="error" close={false}/>
  ))
  .add('Success with link', () => (
    <Toast title="Payment recieved"
      link="click for details" />
  ))
  .add('Warning', () => (
    <Toast message="I'm not sure you should do that" type="warning"/>
  ))
  .add('With Alert', () => (
    <Alert dismissable={true}>
      <p>Hello</p>
    </Alert>
  ))
  .add('Fade out', () => (
    <Fade>
      <Toast message="I'm about to expire" type="warning"/>
    </Fade>
  ))
  .add('With persistent Fader', () => (
    <Fade sticky={true}>
      <Toast message="I'm Going to stick around" type="warning"/>
    </Fade>
  )
);
