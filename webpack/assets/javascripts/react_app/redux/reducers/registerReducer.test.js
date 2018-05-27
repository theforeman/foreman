import store from '../index';
import registerReducer from './registerReducer';

const TEST_REGISTER_REDUCER_ACTION = 'TEST_REGISTER_REDUCER_ACTION';

const exampleReducer = (state = {}, action) => {
  switch (action.type) {
    case TEST_REGISTER_REDUCER_ACTION:
      return Object.assign({}, state, {
        TEST_REGISTER_REDUCER_ACTION: 'success',
      });

    default:
      return state;
  }
};

describe('Registering reducers asyncronously.', () => {
  it('should be able to register reducer after the store was created', () => {
    registerReducer('test_register_reducer', exampleReducer);

    store.dispatch({ type: TEST_REGISTER_REDUCER_ACTION });

    expect(store.getState()).toMatchObject({
      test_register_reducer: {
        TEST_REGISTER_REDUCER_ACTION: 'success',
      },
    });
  });
});
