import { differenceBy, unionBy } from 'lodash';
import { selectAPIResponse } from '../../../redux/API/APISelectors';
import {
  HOST_STATUSES_KEY,
  OK_STATUS_STATE,
  WARNING_STATUS_STATE,
  ERROR_STATUS_STATE,
  NA_STATUS_STATE,
  ALL_STATUS_STATE,
} from './Constants';

const EMPTY_ARRAY = [];

export const selectStatusByState = (state, statusState) => {
  const { statuses } = selectAPIResponse(state, HOST_STATUSES_KEY);
  const notAvailableStatuses = selectSupportedStatusesAsObject(state);
  if (!notAvailableStatuses) return EMPTY_ARRAY;
  switch (statusState) {
    case ALL_STATUS_STATE:
      return statuses?.asMutable() || EMPTY_ARRAY;
    case NA_STATUS_STATE:
      return selectNAStatuses(state);
    case undefined:
      return unionBy(statuses?.asMutable(), notAvailableStatuses, 'name');

    default:
      return (
        statuses?.asMutable().filter(({ global }) => global === statusState) ||
        EMPTY_ARRAY
      );
  }
};

const selectSupportedStatuses = (state) =>
  selectAPIResponse(state, HOST_STATUSES_KEY)?.captions?.asMutable();
const selectSupportedStatusesAsObject = (state) =>
  selectSupportedStatuses(state)?.map((name) => ({
    name,
    date: undefined,
    label: 'N/A',
    link: undefined,
    global: NA_STATUS_STATE,
    reported_at: undefined,
  }));

export const selectErrorStatuses = (state) =>
  selectStatusByState(state, ERROR_STATUS_STATE);
export const selectWarningStatuses = (state) =>
  selectStatusByState(state, WARNING_STATUS_STATE);
export const selectOKStatuses = (state) =>
  selectStatusByState(state, OK_STATUS_STATE);

export const selectNAStatuses = (state) => {
  const supportedStatuses = selectSupportedStatusesAsObject(state);
  const existStatuses = selectStatusByState(state, ALL_STATUS_STATE);
  if (supportedStatuses)
    return differenceBy(supportedStatuses, existStatuses, 'name');
  return EMPTY_ARRAY;
};

export const selectAllSortedStatuses = (state) =>
  selectErrorStatuses(state)
    .concat(selectWarningStatuses(state))
    .concat(selectOKStatuses(state))
    .concat(selectNAStatuses(state));
