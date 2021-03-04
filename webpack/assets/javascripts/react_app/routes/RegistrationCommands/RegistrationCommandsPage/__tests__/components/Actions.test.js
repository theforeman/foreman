import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import Actions from '../../components/Actions';

import { actionsComponentProps } from '../fixtures'

describe('RegistrationCommandsPage - Actions', () => {
  testComponentSnapshotsWithFixtures(Actions, { 'renders': actionsComponentProps });
})
