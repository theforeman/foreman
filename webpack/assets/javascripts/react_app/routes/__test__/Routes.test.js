import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import AppSwitcher from '../';
import { children } from './ForemanSwitcher.fixtures'

const fixtures = {
  'renders routes with chidlren': children,
};

describe('Routes', () => {
  describe('rendering routes with children', () => {
    testComponentSnapshotsWithFixtures(AppSwitcher, fixtures);
  });
});
