import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import OperatingSystem from '../../components/fields/OperatingSystem';

import { osProps } from '../fixtures'

jest.mock('react-redux');

describe('RegistrationCommandsPage fields - OperatingSystem', () => {
  testComponentSnapshotsWithFixtures(OperatingSystem, { 'renders': osProps });
})

