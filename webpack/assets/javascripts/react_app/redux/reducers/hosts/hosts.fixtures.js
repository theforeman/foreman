import Immutable from 'seamless-immutable';
export const initialState = Immutable({
  powerStatus: Immutable({})
});

export const request = {
    id: '2',
    url: 'test'
};

export const response = {
  id: '2',
  data: 'data'
};

export const error = 'some error happened';

export const stateBeforeResponse = Immutable({
  powerStatus: {
    [request.id]: request
  }
});

export const stateAfterSuccess = Immutable({
  powerStatus: Immutable({
    [request.id]: {
      ...response
    }
  })
});

export const stateAfterFailure = Immutable({
  powerStatus: Immutable({
    [request.id]: {
      error
    }
  })
});
