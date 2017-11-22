export const state = {
  status1: {
    1: {
      id: 1,
      type: 'status1',
      status: 'OK',
    },
    2: {
      id: 1,
      type: 'status2',
      status: 'Error',
      message: 'Error TCP Connection',
    },
  },
  status2: {
    1: {
      id: 1,
      type: 'status2',
      success: true,
      message: { message1: 'message1' },
    },
    2: {
      id: 2,
      type: 'status2',
      success: false,
      message: 'Error Type 1',
    },
    3: {
      id: 3,
      type: 'status2',
      success: false,
      message: {
        warning: { message: 'Warning message' },
      },
    },
  },
};
