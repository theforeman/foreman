import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import { noop } from '../../../../common/helpers';

import EditorRadioButton from '../EditorRadioButton';
import { editor } from '../../Editor.fixtures';

const fixtures = {
  'renders EditorRadioButton': {
    stateView: editor.selectedView,
    btnView: editor.selectedView,
    title: 'Editor',
    onClick: noop,
  },
};

describe('EditorRadioButton', () =>
  testComponentSnapshotsWithFixtures(EditorRadioButton, fixtures));
