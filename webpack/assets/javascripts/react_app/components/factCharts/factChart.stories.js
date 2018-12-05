import React from 'react';
import { storiesOf } from '@storybook/react';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import FactChart from './';
import {
  initialState,
  modalSuccessState,
  modalLoadingState,
  modalErrorState,
} from './factChart.fixtures';
import Story from '../../../../../stories/components/Story';

const mockStore = configureMockStore([thunk]);

const dataProp = { id: 1, title: 'test title' };

storiesOf('Page chunks/FactChartModal', module)
  .add('ModalClosed', () => (
    <Story>
      <FactChart
        store={mockStore({ factChart: initialState })}
        data={dataProp}
      />
    </Story>
  ))
  .add('ModalOpen', () => (
    <Story>
      <FactChart
        store={mockStore({ factChart: modalSuccessState })}
        data={dataProp}
      />
    </Story>
  ))
  .add('Loading', () => (
    <Story>
      <FactChart
        store={mockStore({ factChart: modalLoadingState })}
        data={dataProp}
      />
    </Story>
  ))
  .add('No data', () => (
    <Story>
      <FactChart
        store={mockStore({ factChart: modalErrorState })}
        data={dataProp}
      />
    </Story>
  ));
