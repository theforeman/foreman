import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import Insecure from '../../components/fields/Insecure';

import { insecureProps } from '../fixtures'

describe('RegistrationCommandsPage fields - Insecure', () => {
  testComponentSnapshotsWithFixtures(Insecure, { 'renders': insecureProps });
})

