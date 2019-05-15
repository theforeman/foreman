import {
  PASSWORD_STRENGTH_PASSWORD_CHANGED,
  PASSWORD_STRENGTH_PASSWORD_CONFIRMATION_CHANGED,
} from '../PasswordStrengthConstants';

import reducer from '../PasswordStrengthReducer';
import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'should return the initial state': {},

  'should handle PASSWORD_STRENGTH_PASSWORD_CHANGED': {
    action: {
      type: PASSWORD_STRENGTH_PASSWORD_CHANGED,
      payload: 'some-password',
    },
  },

  'should handle PASSWORD_STRENGTH_PASSWORD_CONFIRMATION_CHANGED': {
    action: {
      type: PASSWORD_STRENGTH_PASSWORD_CONFIRMATION_CHANGED,
      payload: 'some-password',
    },
  },
};

describe('PasswordStrength reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
