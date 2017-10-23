import {
  FACT_CHART_DATA_REQUEST,
  FACT_CHART_DATA_SUCCESS,
  FACT_CHART_DATA_FAILURE,
  OPEN_FACT_CHART_MODAL,
  CLOSE_FACT_CHART_MODAL,
} from '../../consts';

import {
  getChartData,
  showModal,
  closeModal,
} from './index';

import { ajaxRequestAction } from '../common';

jest.unmock('./index');
jest.mock('../common');

describe('factCharts actions', () => {
  it('getChartData should call ajaxRequestAction with url and id', () => {
    const id = 1;
    const url = 'url';
    const dispatch = jest.fn();
    const expectedParams =
      {
        dispatch,
        failedAction: FACT_CHART_DATA_FAILURE,
        item: { id },
        requestAction: FACT_CHART_DATA_REQUEST,
        successAction: FACT_CHART_DATA_SUCCESS,
        url,
      };
    const dispatcher = getChartData(url, id);

    dispatcher(dispatch);
    expect(ajaxRequestAction).toBeCalledWith(expectedParams);
  });

  it('should open modal', () => {
    const id = 1;
    const title = 'test title';
    const expectedResults = {
      type: OPEN_FACT_CHART_MODAL,
      payload: { id, title },
    };

    expect(showModal(id, title)).toEqual(expectedResults);
  });

  it('should close modal', () => {
    const id = 1;
    const expectedResults = {
      type: CLOSE_FACT_CHART_MODAL,
      payload: { id },
    };

    expect(closeModal(id)).toEqual(expectedResults);
  });
});

