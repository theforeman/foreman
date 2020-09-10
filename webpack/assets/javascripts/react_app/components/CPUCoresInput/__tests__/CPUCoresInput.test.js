import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import CPUCoresInput from '../CPUCoresInput';

const props = {
  label: 'CPUs',
};

const fixtures = {
  'should render with default props': {
    ...props,
  },
};

describe('CPUCoresInput', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(CPUCoresInput, fixtures));
});
