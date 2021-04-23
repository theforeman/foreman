import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import Packages from '../../components/fields/Packages';

import { packagesProps } from '../fixtures'

describe('RegistrationCommandsPage fields - Packages', () => {
  testComponentSnapshotsWithFixtures(Packages, { 'renders': packagesProps });
})

