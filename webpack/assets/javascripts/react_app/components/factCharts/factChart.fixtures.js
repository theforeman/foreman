import Immutable from 'seamless-immutable';
import { STATUS } from '../../constants';
import { mockStoryData } from '../common/charts/DonutChart/DonutChart.fixtures';

export const chartDataValues = mockStoryData.data.columns;

const state = {
  modalToDisplay: {},
  chartData: [],
  loaderStatus: '',
};

export const initialState = Immutable(state);

export const modalOpenState = Immutable(
  Object.assign(state, { modalToDisplay: { 1: true } })
);

export const modalSuccessState = Immutable(
  Object.assign({}, state, {
    modalToDisplay: { 1: true },
    chartData: chartDataValues,
    loaderStatus: STATUS.RESOLVED,
  })
);

export const modalLoadingState = Immutable(
  Object.assign(state, {
    modalToDisplay: { 1: true },
    loaderStatus: STATUS.PENDING,
  })
);

export const modalErrorState = Immutable(
  Object.assign(state, {
    modalToDisplay: { 1: true },
    loaderStatus: STATUS.ERROR,
  })
);
