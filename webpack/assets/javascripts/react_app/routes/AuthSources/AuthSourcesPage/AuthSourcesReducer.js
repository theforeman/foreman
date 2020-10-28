import Immutable from 'seamless-immutable';
import { AUTH_SOURCES_TABLE_DATA } from './AuthSourcesConstants';

export default (state = Immutable({}), action) => {
  const { type, payload } = action;
  switch (type) {
    case AUTH_SOURCES_TABLE_DATA:
      return state.merge(payload);
    default:
      return state;
  }
};
