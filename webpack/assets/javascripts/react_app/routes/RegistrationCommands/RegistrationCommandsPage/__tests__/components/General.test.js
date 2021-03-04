import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import General from '../../components/General';

import { generalComponentProps } from '../fixtures'

describe('RegistrationCommandsPage - General', () => {
  testComponentSnapshotsWithFixtures(General, { 'renders': generalComponentProps });
})
