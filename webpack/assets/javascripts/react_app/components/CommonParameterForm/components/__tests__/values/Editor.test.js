import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import { editorFixtures } from '../fixtures';
import Editor from '../../values/Editor';


describe('Editor', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(Editor, editorFixtures));
});
