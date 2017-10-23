import {
  FACT_CHART_DATA_REQUEST,
  FACT_CHART_DATA_SUCCESS,
  FACT_CHART_DATA_FAILURE,
  OPEN_FACT_CHART_MODAL,
  CLOSE_FACT_CHART_MODAL,
} from '../../consts';
import { ajaxRequestAction } from '../common';

export const getChartData = (url, id) => dispatch =>
  ajaxRequestAction({
    dispatch,
    requestAction: FACT_CHART_DATA_REQUEST,
    successAction: FACT_CHART_DATA_SUCCESS,
    failedAction: FACT_CHART_DATA_FAILURE,
    url,
    item: { id },
  });

export const showModal = (id, title) => {
  const showModalAction = { type: OPEN_FACT_CHART_MODAL, payload: { id, title } };
  return showModalAction;
};

export const closeModal = (id) => {
  const closeModalAction = ({ type: CLOSE_FACT_CHART_MODAL, payload: { id } });
  return closeModalAction;
};

