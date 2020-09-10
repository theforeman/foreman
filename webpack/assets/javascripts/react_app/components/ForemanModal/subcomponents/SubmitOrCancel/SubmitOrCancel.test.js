import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import SubmitOrCancel from './SubmitOrCancel';

const handlers = {
  submitProps: {
    submitBtnProps: {
      bsStyle: 'default',
      btnText: 'Confirm',
    },
    cancelBtnProps: {
      bsStyle: 'danger',
      btnText: 'Deny',
    },
  },
  onCancel: jest.fn(),
  onSubmit: jest.fn(),
  id: 'test-modal',
};

const fixtures = {
  'should render': {
    isSubmitting: false,
    ...handlers,
  },
  'should render when isSubmitting': {
    isSubmitting: true,
    ...handlers,
  },
};

describe('SubmitOrCancel', () => {
  testComponentSnapshotsWithFixtures(SubmitOrCancel, fixtures);
});
