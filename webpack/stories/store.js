import createLogger from '@theforeman/vendor/redux-logger';
import configureMockStore from 'redux-mock-store';
import thunk from '@theforeman/vendor/redux-thunk';

export default configureMockStore([thunk, createLogger()]);
