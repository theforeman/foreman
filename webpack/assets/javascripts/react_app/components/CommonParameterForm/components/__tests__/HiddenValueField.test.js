import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import { hiddenValueFieldFixtures } from './fixtures';
import HiddenValueField from '../HiddenValueField';

describe('HiddenValueField', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(HiddenValueField, hiddenValueFieldFixtures));
});
