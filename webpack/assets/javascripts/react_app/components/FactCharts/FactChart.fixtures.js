import Immutable from 'seamless-immutable';
import { STATUS } from '../../constants';
import { mockStoryData } from '../common/charts/DonutChart/DonutChart.fixtures';

export const chartDataValues = mockStoryData.data.columns;

export const initialState = Immutable({
  modalToDisplay: {},
  chartData: [],
  loaderStatus: '',
});

export const modalOpenState = initialState.setIn(['modalToDisplay'], {
  1: true,
});

export const modalSuccessState = Immutable.merge(initialState, {
  modalToDisplay: { 1: true },
  chartData: chartDataValues,
  loaderStatus: STATUS.RESOLVED,
});

export const modalLoadingState = Immutable.merge(initialState, {
  modalToDisplay: { 1: true },
  loaderStatus: STATUS.PENDING,
});

export const modalErrorState = Immutable.merge(initialState, {
  modalToDisplay: { 1: true },
  loaderStatus: STATUS.ERROR,
});
