import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import EditorView from '../EditorView';
import { editor } from '../../Editor.fixtures';

const fixtures = {
  'renders EditorView': editor,
  'renders EditorView w/vim&mask': {
    ...editor,
    isMasked: true,
    keyBinding: 'vim',
  },
};

describe('EditorView', () => {
  describe('EditorView', () =>
    testComponentSnapshotsWithFixtures(EditorView, fixtures));
});
