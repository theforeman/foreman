import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import Command from '../../components/Command';

import { commandComponentProps } from '../fixtures'

describe('RegistrationCommandsPage - Command', () => {
  testComponentSnapshotsWithFixtures(Command, { 'renders': commandComponentProps });
})
