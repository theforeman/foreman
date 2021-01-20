import Immutable from 'seamless-immutable';

export const emptyState = Immutable({
  toasts: {
    messages: {},
  },
});

export const toast = {
  message: 'Widget positions successfully saved.',
  type: 'success',
  key: 'test-key',
};

export const singleMessageState = Immutable({
  toasts: {
    messages: { 1: toast },
  },
});

export const singleMessageWithLinkState = Immutable({
  toasts: {
    messages: {
      1: {
        message: 'Widget positions successfully saved.',
        type: 'success',
        link: {
          children: 'hi link!',
          href: 'google.com',
        },
      },
    },
  },
});

export const multipleMessagesState = Immutable({
  toasts: {
    messages: {
      1: {
        message: 'Message number 1.',
        type: 'success',
      },
      2: {
        message: 'Message number 2.',
        type: 'warning',
        link: {
          children: 'google!',
          href: 'google.com',
        },
      },
      3: {
        message: 'Message number 3.',
        type: 'error',
        link: {
          children: 'google!',
          href: 'google.com',
        },
      },
    },
  },
});

export const errorMessageState = Immutable({
  toasts: {
    messages: {
      1: {
        message: 'Widget positions successfully saved.',
        type: 'random',
      },
    },
  },
});

export const warnMessageState = Immutable({
  toasts: {
    messages: {
      1: {
        message: 'Widget positions successfully saved.',
        type: 'notice',
      },
    },
  },
});
