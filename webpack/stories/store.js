import createLogger from 'redux-logger';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

export default configureMockStore([thunk, createLogger()]);
