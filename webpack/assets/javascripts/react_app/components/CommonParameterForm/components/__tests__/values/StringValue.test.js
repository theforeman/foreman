import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import { stringValueFixtures } from '../fixtures';
import StringValue from '../../values/StringValue';


describe('StringValue', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(StringValue, stringValueFixtures));
});
