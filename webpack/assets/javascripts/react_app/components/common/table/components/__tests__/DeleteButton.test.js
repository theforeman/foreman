import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import DeleteButton from '../DeleteButton';

const baseProps = {
  id: 1,
  name: 'KVM',
  controller: 'models',
  onClick: () => {},
};

const fixtures = {
  'should render delete button on active': {
    active: true,
    ...baseProps,
  },
  'should render nothing on inactive': baseProps,
};

describe('DeleteButton', () => {
  testComponentSnapshotsWithFixtures(DeleteButton, fixtures);
});
