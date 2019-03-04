import getTableItemsAction from './getTableItemsAction';
import { ajaxRequestAction } from '../../../../redux/actions/common';

jest.mock('../../../../redux/actions/common');
describe('getTableItemsAction', () => {
  it('should call ajaxRequestAction with url ', () => {
    const controller = 'models';
    const url = '/api/models?include_permissions=true';
    const dispatch = jest.fn();
    const expectedParams = {
      dispatch,
      failedAction: 'MODELS_TABLE_FAILURE',
      requestAction: 'MODELS_TABLE_REQUEST',
      successAction: 'MODELS_TABLE_SUCCESS',
      url,
      item: { controller, url },
    };
    const dispatcher = getTableItemsAction(controller, {}, url);
    dispatcher(dispatch);
    expect(ajaxRequestAction).toBeCalledWith(expectedParams);
  });
});
