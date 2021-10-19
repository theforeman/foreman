import { translate as __ } from '../../../common/I18n';
import { selectAPIResponse } from '../../../redux/API/APISelectors';
import {
  WARNING_STATUS_STATE,
  ERROR_STATUS_STATE,
  OK_STATUS_STATE,
} from '../Status/Constants';
import { REPORT_API_OPTIONS } from './constants';

const statusMapper = status => {
  if (status.failed > 0 || status.failed_restarts > 0) {
    return { status: ERROR_STATUS_STATE, label: __('Failures') };
  }
  if (status.pending > 0) {
    return { status: WARNING_STATUS_STATE, label: __('Pendings') };
  }
  return { status: OK_STATUS_STATE, label: __('No failures nor pendings') };
};

export const selectReportStatuses = state => {
  const statuses = [];
  const { results } = selectAPIResponse(state, REPORT_API_OPTIONS.key);
  results &&
    results.forEach(({ status }) => {
      statuses.push(statusMapper(status));
    });
  return statuses;
};
