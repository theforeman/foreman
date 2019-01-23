import { testActionSnapshotWithFixtures } from 'react-redux-test-utils';
import { ajaxRequestAction } from '../../../redux/actions/common/index';
import { getChartData, showModal, closeModal } from '../FactChartActions';

import * as types from '../FactChartConstants';

jest.unmock('../FactChartActions');
jest.mock('../../../redux/actions/common');

describe('factCharts actions', () => {
  it('getChartData should call ajaxRequestAction with url and id', () => {
    const id = 1;
    const url = 'url';
    const dispatch = jest.fn();
    const expectedParams = {
      dispatch,
      failedAction: types.FACT_CHART_FAILURE,
      item: { id },
      requestAction: types.FACT_CHART_REQUEST,
      successAction: types.FACT_CHART_SUCCESS,
      url,
    };
    const dispatcher = getChartData(url, id);

    dispatcher(dispatch);
    expect(ajaxRequestAction).toBeCalledWith(expectedParams);
  });
});

const fixtures = {
  'should open modal': () => showModal(1, 'test title'),
  'should close modal': () => closeModal(1),
};

describe('FactCharts actions', () => testActionSnapshotWithFixtures(fixtures));
