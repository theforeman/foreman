import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import createLogger from 'redux-logger';

export default configureMockStore([thunk, createLogger()]);
