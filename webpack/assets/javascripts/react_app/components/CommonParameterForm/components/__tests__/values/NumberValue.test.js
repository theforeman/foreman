import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import { numberValueFixtures } from '../fixtures';
import NumberValue from '../../values/NumberValue';


describe('NumberValue', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(NumberValue, numberValueFixtures));
});
