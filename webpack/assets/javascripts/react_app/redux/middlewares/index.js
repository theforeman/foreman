import createLogger from 'redux-logger';
import thunk from 'redux-thunk';
import { routerMiddleware } from 'connected-react-router';
import { APIMiddleware } from '../API';
import { IntervalMiddleware } from './IntervalMiddleware';
import history from '../../history';

const logReduxToConsole = () => {
  const isProduction = process.env.NODE_ENV === 'production';
  const isLogger = process.env.REDUX_LOGGER;

  if (!isProduction && !global.__testing__) {
    if (isLogger === undefined || isLogger === true) return true;
  }
  return isProduction && isLogger;
};

export const middlewares = [
  thunk,
  IntervalMiddleware,
  APIMiddleware,
  routerMiddleware(history),
  ...(logReduxToConsole() ? [createLogger()] : []),
];
