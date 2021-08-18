import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import { noop } from '../../../../common/helpers';

import EditorSettings from '../EditorSettings';
import { dropdowns } from '../../Editor.fixtures';

const fixtures = {
  'renders EditorSettings': {
    ...dropdowns,
    mode: 'Ruby',
    selectedView: 'input',
    theme: 'Github',
    autocompletion: true,
    liveAutocompletion: false,
    keyBinding: 'vim',
    changeSetting: noop,
  },
  'renders EditorSettings w/preview': {
    ...dropdowns,
    mode: 'Ruby',
    selectedView: 'preview',
    theme: 'Github',
    autocompletion: true,
    liveAutocompletion: false,
    keyBinding: 'vim',
    changeSetting: noop,
  },
};

describe('EditorSettings', () =>
  testComponentSnapshotsWithFixtures(EditorSettings, fixtures));
