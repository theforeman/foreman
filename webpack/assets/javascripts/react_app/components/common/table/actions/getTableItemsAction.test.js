import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { getTableItemsAction, changeTablePage } from './getTableItemsAction';
import { ajaxRequestAction } from '../../../../redux/actions/common';

jest.mock('../../../../redux/actions/common');

const fixtures = {
  'should changeTablePage': () =>
    changeTablePage('models_table', { page: 2, perPage: 5 }),
};

describe('getTableItemsAction', () => {
  it('should call ajaxRequestAction with url ', () => {
    const tableID = 'models_table';
    const url = '/api/models?include_permissions=true';
    const dispatch = jest.fn();
    const expectedParams = {
      dispatch,
      failedAction: 'MODELS_TABLE_FAILURE',
      requestAction: 'MODELS_TABLE_REQUEST',
      successAction: 'MODELS_TABLE_SUCCESS',
      url,
      item: { tableID, url },
    };
    const dispatcher = getTableItemsAction(tableID, {}, url);
    dispatcher(dispatch);
    expect(ajaxRequestAction).toBeCalledWith(expectedParams);
  });
  testActionSnapshotWithFixtures(fixtures);
});
