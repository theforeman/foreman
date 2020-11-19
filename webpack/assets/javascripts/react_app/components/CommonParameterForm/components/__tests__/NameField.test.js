import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import { nameFieldFixtures } from './fixtures';
import NameField from '../NameField';

describe('NameField', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(NameField, nameFieldFixtures));
});
