import {
  FACT_CHART_REQUEST,
  FACT_CHART_SUCCESS,
  FACT_CHART_FAILURE,
  FACT_CHART_MODAL_OPEN,
  FACT_CHART_MODAL_CLOSE,
} from './FactChartConstants';

import { ajaxRequestAction } from '../../redux/actions/common/index';

export const getChartData = (url, id) => dispatch =>
  ajaxRequestAction({
    dispatch,
    requestAction: FACT_CHART_REQUEST,
    successAction: FACT_CHART_SUCCESS,
    failedAction: FACT_CHART_FAILURE,
    url,
    item: { id },
  });

export const showModal = (id, title) => {
  const showModalAction = {
    type: FACT_CHART_MODAL_OPEN,
    payload: { id, title },
  };
  return showModalAction;
};

export const closeModal = id => {
  const closeModalAction = { type: FACT_CHART_MODAL_CLOSE, payload: { id } };
  return closeModalAction;
};
