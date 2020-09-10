import Immutable from 'seamless-immutable';
import { HOST_POWER_STATUS } from './PowerStatusConstants';
import { STATUS } from '../../../constants';

const id = 1;

const error = new Error('some_error');

const statusText = 'some_status_text';

const state = 'on';

const url = 'test_url';

export const key = `${HOST_POWER_STATUS}_${id}`;

export const pendingProps = { state: undefined };

export const errorProps = { title: error.message, state: 'na' };

export const successProps = { title: statusText, state };

export const successWithOffProps = { title: statusText, state: 'off' };

export const serverProps = { id, url };

export const pendingStore = Immutable({
  API: {
    [key]: {
      response: {},
      status: STATUS.PENDING,
    },
  },
});

export const errorStore = Immutable({
  API: {
    [key]: {
      response: error,
      status: STATUS.ERROR,
    },
  },
});

export const resolvedStore = Immutable({
  API: {
    [key]: {
      response: successProps,
      status: STATUS.RESOLVED,
    },
  },
});

export const resolvedStoreWithOff = Immutable({
  API: {
    [key]: {
      response: successWithOffProps,
      status: STATUS.RESOLVED,
    },
  },
});
