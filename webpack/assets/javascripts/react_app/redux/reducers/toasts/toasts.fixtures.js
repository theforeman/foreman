import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  messages: {},
  counter: 0,
  visibilityFilter: 'all'
});

export const messageBeforeAdd = {
  type: 'success',
  message: 'first message',
  visible: true
};

export const stateAfterAdd = Immutable({
  messages: {
    1: {
      type: 'success',
      message: 'first message',
      visible: true,
      id: '1'
    }
  },
  counter: 1,
  visibilityFilter: 'all'
});

export const stateAfterHide = Immutable({
  messages: {
    1: {
      type: 'success',
      message: 'first message',
      visible: false,
      id: '1'
    }
  },
  counter: 1,
  visibilityFilter: 'all'
});

export const stateAfterDelete = Immutable({
  messages: {},
  counter: 1,
  visibilityFilter: 'all'
});
