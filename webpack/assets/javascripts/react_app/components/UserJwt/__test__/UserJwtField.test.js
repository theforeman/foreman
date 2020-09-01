import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import UserJwtField from '../components/UserJwtField';
import { fieldOk, fieldError, fieldPending } from './fixtures';

const fixtures = {
  ok: fieldOk,
  error: fieldError,
  pending: fieldPending,
};

describe('UserJwtField', () => {
  testComponentSnapshotsWithFixtures(UserJwtField, fixtures);
});
