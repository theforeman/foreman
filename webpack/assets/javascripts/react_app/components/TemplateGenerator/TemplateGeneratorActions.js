/* eslint-disable promise/prefer-await-to-then */
import { saveAs } from 'file-saver';
import { API } from '../../redux/API';

import {
  TEMPLATE_GENERATE_REQUEST,
  TEMPLATE_GENERATE_POLLING,
  TEMPLATE_GENERATE_SUCCESS,
  TEMPLATE_GENERATE_FAILURE,
} from './TemplateGeneratorConstants';

const pollingInterval = 3000;

export const generateTemplate = (url, templateInputData) => dispatch => {
  dispatch({
    type: TEMPLATE_GENERATE_REQUEST,
    payload: { ...templateInputData },
  });
  return API.post(url, templateInputData)
    .then(({ data }) => {
      dispatch(pollReportData(data.data_url));
    })
    .catch(error =>
      dispatch({
        type: TEMPLATE_GENERATE_FAILURE,
        payload: { error, item: templateInputData },
      })
    );
};

const _downloadFile = response => {
  const blob = new Blob([response.data], {
    type: response.headers['content-type'],
  });
  const filename = response.headers['content-disposition'].match(
    /filename="(.*)"/
  );
  saveAs(blob, (filename && filename[1]) || 'report.txt');
};

const _getErrors = errorResponse => {
  if (!errorResponse || !errorResponse.data) return null;
  if (errorResponse.status === 422) return errorResponse.data.errors;
  if (errorResponse.data.error) return [errorResponse.data.error]; // most of >500
  return [errorResponse.data];
};

export const pollReportData = pollUrl => dispatch => {
  dispatch({ type: TEMPLATE_GENERATE_POLLING, payload: { url: pollUrl } });

  return API.get(pollUrl, { responseType: 'blob' })
    .then(response => {
      if (response.status === 200) {
        dispatch({ type: TEMPLATE_GENERATE_SUCCESS, payload: {} });
        _downloadFile(response);
      } else if (pollingInterval) {
        setTimeout(() => dispatch(pollReportData(pollUrl)), pollingInterval);
      }
    })
    .catch(error => {
      dispatch({
        type: TEMPLATE_GENERATE_FAILURE,
        payload: { error, messages: _getErrors(error.response) },
      });
    });
};
