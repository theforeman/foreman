import immutable from 'seamless-immutable';

export const pendingState = {
  hosts: immutable({
    powerStatus: immutable({}),
  }),
};

export const errorState = {
  hosts: immutable({
    powerStatus: immutable({
      1: {
        error: 'someError',
      },
    }),
  }),
};

export const resolvedState = {
  hosts: immutable({
    powerStatus: immutable({
      1: {
        state: 'on',
        title: 'On',
      },
      2: {
        state: 'off',
        title: 'Off',
      },
    }),
  }),
};
