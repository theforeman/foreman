import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import { valueFieldFixtures } from './fixtures';
import ValueField from '../ValueField';

describe('ValueField', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ValueField, valueFieldFixtures));
});
