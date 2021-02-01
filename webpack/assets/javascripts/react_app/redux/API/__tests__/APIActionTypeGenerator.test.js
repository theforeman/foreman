import { actionTypeGenerator } from '../';

describe('actionTypeGenerator', () => {
  it('should generate action types', () => {
    expect(actionTypeGenerator('TEST')).toEqual({
      REQUEST: 'TEST_REQUEST',
      SUCCESS: 'TEST_SUCCESS',
      FAILURE: 'TEST_FAILURE',
      UPDATE: 'TEST_UPDATE',
    });
  });
  it('should generate action types with custom types', () => {
    expect(actionTypeGenerator('TEST', { SUCCESS: 'CUSTOM_SUCCESS' })).toEqual({
      REQUEST: 'TEST_REQUEST',
      SUCCESS: 'CUSTOM_SUCCESS',
      FAILURE: 'TEST_FAILURE',
      UPDATE: 'TEST_UPDATE',
    });
  });
});
