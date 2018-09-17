import reducer from './index';
import * as types from '../../consts';

import {
  initialState,
  modalOpenState,
  modalSuccessState,
  modalLoadingState,
  modalErrorState,
  chartDataValues,
} from '../../../components/factCharts/factChart.fixtures';

describe('factCharts reducers', () => {
  it('initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should handle FACT_CHART_DATA_REQUEST action', () => {
    expect(
      reducer(modalOpenState, {
        type: types.FACT_CHART_DATA_REQUEST,
        payload: { id: 1 },
      })
    ).toEqual(modalLoadingState);
  });

  it('should handle FACT_CHART_DATA_SUCCESS action', () => {
    expect(
      reducer(modalLoadingState, {
        type: types.FACT_CHART_DATA_SUCCESS,
        payload: { values: chartDataValues },
      })
    ).toEqual(modalSuccessState);
  });

  it('should handle FACT_CHART_DATA_ERROR action', () => {
    expect(
      reducer(modalLoadingState, {
        type: types.FACT_CHART_DATA_FAILURE,
        payload: {},
      })
    ).toEqual(modalErrorState);
  });

  it('should not display modal', () => {
    expect(
      reducer(modalSuccessState, {
        type: types.CLOSE_FACT_CHART_MODAL,
        payload: {},
      })
    ).toEqual(initialState);
  });
});
