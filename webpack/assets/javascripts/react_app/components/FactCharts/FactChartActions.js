import {
  FACT_CHART_MODAL_OPEN,
  FACT_CHART_MODAL_CLOSE,
} from './FactChartConstants';
import { get } from '../../redux/API';

export const openModal = ({ id, title, apiKey, apiUrl }) => dispatch => {
  dispatch(get({ key: apiKey, url: apiUrl }));
  dispatch({
    type: FACT_CHART_MODAL_OPEN,
    payload: { id, title },
  });
};

export const closeModal = id => ({
  type: FACT_CHART_MODAL_CLOSE,
  payload: { id },
});
