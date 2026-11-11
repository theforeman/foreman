// replaces @theforeman/test.js
import MockAdapter from 'axios-mock-adapter';

import {
  mockWindowLocation,
  classFunctionUnitTest,
  runActionInDepth,
  testActionSnapshot,
  testActionSnapshotWithFixtures,
  testReducerSnapshotWithFixtures,
  testSelectorsSnapshotWithFixtures,
  initMockStore,
} from './assets/javascripts/react_app/common/testHelpers';

export {
  mockWindowLocation,
  classFunctionUnitTest,
  runActionInDepth,
  testActionSnapshot,
  testActionSnapshotWithFixtures,
  testReducerSnapshotWithFixtures,
  testSelectorsSnapshotWithFixtures,
  initMockStore,
  MockAdapter,
};
