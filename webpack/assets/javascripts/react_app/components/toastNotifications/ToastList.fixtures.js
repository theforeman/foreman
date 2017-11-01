import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  toasts: {
    messages: {},
  },
});

export const singleMessageState = Immutable({
  toasts: {
    messages: {
      1: {
        message: 'Widget positions successfully saved.',
        type: 'success',
      },
    },
  },
});

export const singleMessageWithLinkState = Immutable({
  toasts: {
    messages: {
      1: {
        message: 'Widget positions successfully saved.',
        type: 'success',
        link: {
          title: 'hi link!',
          href: 'google.com',
        },
      },
    },
  },
});
