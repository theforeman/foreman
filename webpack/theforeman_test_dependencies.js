// replaces @theforeman/test.js
import { shallow, mount, render, configure } from 'enzyme';
import MockAdapter from 'axios-mock-adapter';

import {
  mockWindowLocation,
  classFunctionUnitTest,
  shallowRenderComponentWithFixtures,
  testComponentSnapshotsWithFixtures,
  runActionInDepth,
  testActionSnapshot,
  testActionSnapshotWithFixtures,
  testReducerSnapshotWithFixtures,
  testSelectorsSnapshotWithFixtures,
  initMockStore,
} from './assets/javascripts/react_app/common/testHelpers';
import IntegrationTestHelper from './assets/javascripts/react_app/common/IntegrationTestHelper';

export {
  mockWindowLocation,
  classFunctionUnitTest,
  shallowRenderComponentWithFixtures,
  testComponentSnapshotsWithFixtures,
  runActionInDepth,
  testActionSnapshot,
  testActionSnapshotWithFixtures,
  testReducerSnapshotWithFixtures,
  testSelectorsSnapshotWithFixtures,
  initMockStore,
  IntegrationTestHelper,
  shallow,
  mount,
  render,
  configure,
  MockAdapter,
};
