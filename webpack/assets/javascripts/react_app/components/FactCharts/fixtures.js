import Immutable from 'seamless-immutable';
import { STATUS } from '../../constants';
import { noop } from '../../common/helpers';

export const id = 1;
export const url = 'some/url';
export const key = `FACT_CHART_${id}`;
export const title = 'some_title';
export const search = 'some-search';
export const status = STATUS.RESOLVED;
export const hostsCount = 100;
export const modalToDisplay = { 1: true };
export const openModal = noop;
export const closeModal = noop;
export const chartData = [
  ['Debian 8', 1],
  ['Fedora 27', 2],
  ['Fedora 26', 1],
];

export const initialState = Immutable({
  modalToDisplay: {},
});

export const modalOpenState = initialState.merge({ modalToDisplay });

export const modalSuccessState = Immutable.merge(initialState, {
  modalToDisplay,
  chartData,
});

export const modalLoadingState = Immutable.merge(initialState, {
  modalToDisplay,
});

export const modalErrorState = Immutable.merge(initialState, {
  modalToDisplay,
});

export const props = {
  id,
  title,
  search,
  status,
  hostsCount,
  chartData,
  modalToDisplay: true,
  openModal,
  closeModal,
};
