import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import TokenLifeTime from '../../components/fields/TokenLifeTime';

import { tokenLifeTimeProps } from '../fixtures'

describe('RegistrationCommandsPage fields - TokenLifeTime', () => {
  testComponentSnapshotsWithFixtures(TokenLifeTime, { 'renders': tokenLifeTimeProps });
})

