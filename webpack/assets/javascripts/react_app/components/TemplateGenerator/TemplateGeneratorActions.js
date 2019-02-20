import { saveAs } from 'file-saver';
import API from '../../API';

import {
  TEMPLATE_GENERATE_REQUEST,
  TEMPLATE_GENERATE_POLLING,
  TEMPLATE_GENERATE_SUCCESS,
  TEMPLATE_GENERATE_FAILURE,
} from './TemplateGeneratorConstants';

const defaultPollingInterval = 2500;
const pollingInterval =
  process.env.NOTIFICATIONS_POLLING || defaultPollingInterval;

export const generateTemplate = (url, templateInputData) => dispatch => {
  dispatch({
    type: TEMPLATE_GENERATE_REQUEST,
    payload: { ...templateInputData },
  });
  return API.post(url, templateInputData)
    .then(({ data }) => {
      dispatch(pollGeneratedResult(data.data_url));
    })
    .catch(error =>
      dispatch({
        type: TEMPLATE_GENERATE_FAILURE,
        payload: { error, item: templateInputData },
      })
    );
};

const pollGeneratedResult = pollUrl => dispatch => {
  dispatch({ type: TEMPLATE_GENERATE_POLLING, payload: { url: pollUrl } });

  return API.get(pollUrl, { responseType: 'blob' })
    .then(response => {
      if (response.status === 200) {
        dispatch({ type: TEMPLATE_GENERATE_SUCCESS, payload: {} });
        const blob = new Blob([response.data], {
          type: response.headers['content-type'],
        });
        const filename = response.headers['content-disposition'].match(
          /filename="(.*)"/
        );
        saveAs(blob, (filename && filename[1]) || 'report.txt');
      } else if (pollingInterval) {
        setTimeout(
          () => dispatch(pollGeneratedResult(pollUrl)),
          pollingInterval
        );
      }
    })
    .catch(error =>
      dispatch({
        type: TEMPLATE_GENERATE_FAILURE,
        payload: { error, item: {} },
      })
    );
};
