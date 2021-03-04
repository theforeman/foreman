import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import Repository from '../../components/fields/Repository';

import { repositoryProps } from '../fixtures'

describe('RegistrationCommandsPage fields - Repository', () => {
  testComponentSnapshotsWithFixtures(Repository, { 'renders': repositoryProps });
})

