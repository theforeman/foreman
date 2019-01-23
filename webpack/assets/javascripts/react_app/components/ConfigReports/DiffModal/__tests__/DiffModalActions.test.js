import { testActionSnapshotWithFixtures } from 'react-redux-test-utils';
import { toggleModal, createDiff, changeViewType } from '../DiffModalActions';

import { diffModalMock } from '../DiffModal.fixtures';

const fixtures = {
  'should toggleModal': () => toggleModal(),

  'should createDiff': () =>
    createDiff(diffModalMock.diff, diffModalMock.title),

  'should changeViewType': () => changeViewType('unified'),
};

describe('DiffModal actions', () => testActionSnapshotWithFixtures(fixtures));
