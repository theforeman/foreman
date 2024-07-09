import { testComponentSnapshotsWithFixtures } from 'foremanReact/common/testHelpers';
import NameCell from '../NameCell';

const fixtures = {
  'should render active link': {
    active: true,
    id: 1,
    name: 'KVM',
    controller: 'models',
  },
  'should render disabled link': {
    id: 2,
    name: 'HyperV',
    controller: 'models',
  },
};

describe('NameCell', () =>
  testComponentSnapshotsWithFixtures(NameCell, fixtures));
