import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import { booleanValueFixtures } from '../fixtures';
import BooleanValue from '../../values/BooleanValue';


describe('BooleanValue', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(BooleanValue, booleanValueFixtures));
});
