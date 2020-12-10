import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import SkeletonLoader from '.';

const fixtures = {
  'should loading true': {
    isLoading: true,
    skeletonProps: { count: 3 },
  },
  'should loading false': {
    isLoading: false,
    emptyState: 'custom empty',
  },
};

describe('SkeletonLoader', () =>
  testComponentSnapshotsWithFixtures(SkeletonLoader, fixtures));
