import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import Taxonomies from '../../components/fields/Taxonomies';

import { taxonomiesProps } from '../fixtures'

describe('RegistrationCommandsPage fields - Taxonomies', () => {
  testComponentSnapshotsWithFixtures(Taxonomies, { 'renders': taxonomiesProps });
})

