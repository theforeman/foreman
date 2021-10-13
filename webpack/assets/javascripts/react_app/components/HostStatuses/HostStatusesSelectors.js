import { selectAPIResponse } from '../../redux/API/APISelectors';
import {
  GLOBAL_STATUS_OK,
  GLOBAL_STATUS_WARN,
  GLOBAL_STATUS_ERROR,
  HOST_STATUSES_KEY,
} from './HostStatusesConstants';

export const selectHostStatuses = (state) =>
  selectAPIResponse(state, HOST_STATUSES_KEY)?.results || [];

export const selectHostStatusesNames = (state) =>
  selectHostStatuses(state).map(({ name }) => name);

export const selectHostStatus = (state, statusName) =>
  selectHostStatuses(state).find(({ name }) => name === statusName);

export const selectHostStatusDetails = (state, statusName) =>
  selectHostStatus(state, statusName)?.details || [];

export const selectHostStatusDescription = (state, statusName) =>
  selectHostStatus(state, statusName)?.description || '';

/* eslint-disable camelcase */
export const selectHostStatusOkTotalPath = (state, statusName) =>
  selectHostStatus(state, statusName)?.ok_total_path;

export const selectHostStatusOkOwnedPath = (state, statusName) =>
  selectHostStatus(state, statusName)?.ok_owned_path;

export const selectHostStatusWarnTotalPath = (state, statusName) =>
  selectHostStatus(state, statusName)?.warn_total_path;

export const selectHostStatusWarnOwnedPath = (state, statusName) =>
  selectHostStatus(state, statusName)?.warn_owned_path;

export const selectHostStatusErrorTotalPath = (state, statusName) =>
  selectHostStatus(state, statusName)?.error_owned_path;

export const selectHostStatusErrorOwnedPath = (state, statusName) =>
  selectHostStatus(state, statusName)?.error_total_path;
/* eslint-enable camelcase */

export const selectHostStatusTotalPaths = (state, statusName) => ({
  okTotalPath: selectHostStatusOkTotalPath(state, statusName),
  warnTotalPath: selectHostStatusWarnTotalPath(state, statusName),
  errorTotalPath: selectHostStatusErrorTotalPath(state, statusName),
});

export const selectHostStatusOwnedPaths = (state, statusName) => ({
  okOwnedPath: selectHostStatusOkOwnedPath(state, statusName),
  warnOwnedPath: selectHostStatusWarnOwnedPath(state, statusName),
  errorOwnedPath: selectHostStatusErrorOwnedPath(state, statusName),
});

export const selectGlobalStatus = (state, statusName) =>
  Math.max(
    ...selectHostStatusDetails(state, statusName)
      .filter(({ total }) => total > 0)
      .map(({ global_status: gs }) => gs),
    0
  );

export const selectHostStatusCounter = (state, statusName) => {
  const calculate = (acc, { total, owned }) => ({
    total: acc.total + total,
    owned: acc.owned + owned,
  });

  const details = selectHostStatusDetails(state, statusName);

  return {
    unknown: details
      .filter(({ global_status: gs }) => gs === null)
      .reduce(calculate, { total: 0, owned: 0 }),
    ok: details
      .filter(({ global_status: gs }) => gs === GLOBAL_STATUS_OK)
      .reduce(calculate, { total: 0, owned: 0 }),
    warn: details
      .filter(({ global_status: gs }) => gs === GLOBAL_STATUS_WARN)
      .reduce(calculate, { total: 0, owned: 0 }),
    error: details
      .filter(({ global_status: gs }) => gs === GLOBAL_STATUS_ERROR)
      .reduce(calculate, { total: 0, owned: 0 }),
  };
};
