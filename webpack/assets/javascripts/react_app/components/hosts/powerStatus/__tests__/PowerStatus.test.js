import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import PowerStatus from '../PowerStatus';
import {
  pendingProps,
  errorProps,
  successProps,
  successWithOffProps,
} from '../PowerStatus.fixtures';

const fixtures = {
  'should render power status with spinner': pendingProps,
  'should render power status with error': errorProps,
  'should render power status when resolved with on': successProps,
  'should render power status when resolved with off': successWithOffProps,
};

describe('PowerStatusInner', () =>
  testComponentSnapshotsWithFixtures(PowerStatus, fixtures));
