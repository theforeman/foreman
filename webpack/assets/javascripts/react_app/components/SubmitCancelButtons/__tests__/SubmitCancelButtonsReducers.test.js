import { SUBMIT_CLICKED, SUBMIT_AND_CANCEL_RESET, CANCEL_CLICKED } from '../SubmitCancelButtonsConsts';
import reducer from '../SubmitCancelButtonsReducers';
import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'should return initial state when state empty': {},
  'should handle SUBMIT_CLICKED': { action: { type: SUBMIT_CLICKED } },
  'should handle CANCEL_CLICKED': { action: { type: CANCEL_CLICKED } },
  'should handle SUBMIT_AND_CANCEL_RESET': { action: { type: SUBMIT_AND_CANCEL_RESET } },
};

describe('SubmitCancelButtons reducer', () => {
  testReducerSnapshotWithFixtures(reducer, fixtures);
});
