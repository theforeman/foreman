import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import ForemanSwitcher from '../ForemanSwitcher/ForemanSwitcher';
import { routes } from './ForemanSwitcher.fixtures'

const fixtures = {
  'renders ForemanSwitcher with routes': routes,
};

describe('ForemanSwitcher', () => {
  describe('rendering routes', () => {
    testComponentSnapshotsWithFixtures(ForemanSwitcher, fixtures);
  });
});
