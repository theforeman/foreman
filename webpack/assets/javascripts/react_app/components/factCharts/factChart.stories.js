import React from 'react';
import { storiesOf } from '@storybook/react';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import FactChart from './';
import { initialState, modalSuccessState, modalLoadingState, modalErrorState } from './factChart.fixtures';

const mockStore = configureMockStore([thunk]);

const dataProp = { id: 1, title: 'test title' };

storiesOf('Components/FactChartModal', module)
  .add('ModalClosed', () => (
      <FactChart
        store={ mockStore({ factChart: initialState }) }
        data={ dataProp }
      />
  ))
  .add('ModalOpen', () => (
      <FactChart
        store={ mockStore({ factChart: modalSuccessState }) }
        data ={ dataProp }
      />
  ))
  .add('Loading', () => (
      <FactChart
        store={ mockStore({ factChart: modalLoadingState }) }
        data={ dataProp }
      />
  ))
  .add('No data', () => (
    <FactChart
      store={ mockStore({ factChart: modalErrorState }) }
      data={ dataProp }
    />
  ));
