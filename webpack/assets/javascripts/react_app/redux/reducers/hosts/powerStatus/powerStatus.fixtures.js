import Immutable from 'seamless-immutable';

export const initialState = Immutable({});

export const failResponse = {
  data: {
    id: '2',
    state: 'na',
    title: 'N/A',
    statusText: 'Failed to fetch power status',
  },
};

export const request = {
  id: '2',
  url: 'test',
};

export const response = {
  id: '2',
  data: 'data',
};

export const error = {
  message: 'some error happened',
  response: failResponse,
};

export const stateBeforeResponse = Immutable({
  [request.id]: request,
});
