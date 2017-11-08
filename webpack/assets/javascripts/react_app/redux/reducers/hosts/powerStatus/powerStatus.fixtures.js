import Immutable from 'seamless-immutable';

export const initialState = Immutable({});

export const request = {
  id: '2',
  url: 'test',
};

export const response = {
  id: '2',
  data: 'data',
};

export const error = 'some error happened';

export const stateBeforeResponse = Immutable({
  [request.id]: request,
});

export const stateAfterSuccess = Immutable({
  [request.id]: {
    ...response,
  },
});

export const stateAfterFailure = Immutable({
  [request.id]: {
    error,
  },
});
