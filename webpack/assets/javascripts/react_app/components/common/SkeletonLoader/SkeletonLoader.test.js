import React from 'react';
import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import SkeletonLoader from '.';
import { STATUS } from '../../../constants';
const fixtures = {
  'should loading true': {
    status: STATUS.PENDING,
    skeletonProps: { count: 3 },
  },
  'should loading finished with no children': {
    status: STATUS.RESOLVED,
    emptyState: 'custom empty',
  },
  'should loading true with a node child': {
    status: STATUS.RESOLVED,
    emptyState: 'custom empty',
    children: <div>a child</div>,
  },
  'should render custom error': {
    status: STATUS.ERROR,
    errorNode: "custom error node"
  },
};

describe('SkeletonLoader', () =>
  testComponentSnapshotsWithFixtures(SkeletonLoader, fixtures));
