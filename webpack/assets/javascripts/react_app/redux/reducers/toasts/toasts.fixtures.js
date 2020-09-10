import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  messages: {},
});

export const messageBeforeAdd = {
  type: 'success',
  message: 'first message',
};

export const stateAfterAdd = Immutable({
  messages: {
    1: {
      type: 'success',
      message: 'first message',
    },
  },
});
