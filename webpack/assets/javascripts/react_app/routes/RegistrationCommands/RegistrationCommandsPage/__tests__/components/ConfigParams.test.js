import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import ConfigParams from '../../components/fields/ConfigParams';

import { configParamsProps } from '../fixtures'

describe('RegistrationCommandsPage fields - ConfigParams', () => {
  testComponentSnapshotsWithFixtures(ConfigParams, { 'renders': configParamsProps });
})

