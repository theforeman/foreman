import React from 'react';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import FactChart from '.';
import {
  initialState,
  modalSuccessState,
  modalLoadingState,
  modalErrorState,
} from './FactChart.fixtures';
import Story from '../../../../../stories/components/Story';

const mockStore = configureMockStore([thunk]);

const dataProp = { id: 1, title: 'test title' };

export default {
  title: 'Page chunks/FactChartModal',
};

export const modalClosed = () => (
  <Story>
    <FactChart store={mockStore({ factChart: initialState })} data={dataProp} />
  </Story>
);

modalClosed.story = {
  name: 'ModalClosed',
};

export const modalOpen = () => (
  <Story>
    <FactChart
      store={mockStore({ factChart: modalSuccessState })}
      data={dataProp}
    />
  </Story>
);

modalOpen.story = {
  name: 'ModalOpen',
};

export const loading = () => (
  <Story>
    <FactChart
      store={mockStore({ factChart: modalLoadingState })}
      data={dataProp}
    />
  </Story>
);

export const noData = () => (
  <Story>
    <FactChart
      store={mockStore({ factChart: modalErrorState })}
      data={dataProp}
    />
  </Story>
);

noData.story = {
  name: 'No data',
};
