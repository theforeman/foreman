import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import EditorModal from '../EditorModal';
import { editorOptions } from '../../Editor.fixtures';

const fixtures = {
  'renders EditorModal editor': {
    ...editorOptions,
    editorValue: '</>',
    onHide: jest.fn(),
  },
  'renders EditorModal diff': {
    ...editorOptions,
    selectedView: 'diff',
    editorValue: '</>',
    onHide: jest.fn(),
  },
};

describe('EditorModal', () => {
  describe('should render', () =>
    testComponentSnapshotsWithFixtures(EditorModal, fixtures));
});
