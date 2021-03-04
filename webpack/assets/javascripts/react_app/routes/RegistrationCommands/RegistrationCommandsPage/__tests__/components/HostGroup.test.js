import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import HostGroup from '../../components/fields/HostGroup';

import { hostGroupProps } from '../fixtures'

describe('RegistrationCommandsPage fields - HostGroup', () => {
  testComponentSnapshotsWithFixtures(HostGroup, { 'renders': hostGroupProps });
})

