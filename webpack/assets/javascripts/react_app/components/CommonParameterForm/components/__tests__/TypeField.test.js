import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import { typeFieldFixtures } from './fixtures';
import TypeField from '../TypeField';

describe('TypeField', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(TypeField, typeFieldFixtures));
});
