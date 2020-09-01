import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import UserJwtForm from '../components/UserJwtForm';
import { formProps } from './fixtures';

describe('UserJwtForm', () => {
  testComponentSnapshotsWithFixtures(UserJwtForm, { 'render ok': formProps });
});
