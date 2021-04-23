import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import SmartProxy from '../../components/fields/SmartProxy';

import { smartProxyProps } from '../fixtures'

describe('RegistrationCommandsPage fields - SmartProxy', () => {
  testComponentSnapshotsWithFixtures(SmartProxy, { 'renders': smartProxyProps });
})

