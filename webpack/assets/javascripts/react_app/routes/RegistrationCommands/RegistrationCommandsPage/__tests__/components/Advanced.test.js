import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import Advanced from '../../components/Advanced';

import { advancedComponentProps } from '../fixtures'


describe('RegistrationCommandsPage - Advanced', () => {
  testComponentSnapshotsWithFixtures(Advanced, { 'renders': advancedComponentProps });
})
