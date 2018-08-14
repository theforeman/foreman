import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import WrappedComponent from '../BasicWrappedComponent';
import { wrapComponentWithTour } from '../Tour';

jest.unmock('../');

const createStubs = () => ({
  startRunning: jest.fn(),
  stopRunning: jest.fn(),
  registerTour: jest.fn(),
});
const steps = [
  {
    selector: '[data-tut="key_1"]',
    content: 'Step 1',
  },
  {
    selector: '[data-tut="key_2"]',
    content: 'Step 2',
  },
  {
    selector: '[data-tut="key_3"]',
    content: 'Step 3',
  },
];

const fixtures = {
  'renders breadcrumb-bar': {
    activeTour: ['some-id', true],
    ...createStubs(),
  },
};

describe('WithTour', () => {
  const TourComponent = wrapComponentWithTour(WrappedComponent, steps, 'id-1');

  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(TourComponent, fixtures));
});
