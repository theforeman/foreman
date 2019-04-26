import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import { noop } from '../../../../common/helpers';

import EditorHostSelect from '../EditorHostSelect';
import { editorOptions } from '../../Editor.fixtures';

const fixtures = {
  'renders EditorHostSelect': {
    show: true,
    open: true,
    selectedItem: { id: '1', name: 'one' },
    onToggle: noop,
    searchQuery: '',
    onSearchChange: noop,
    onSearchClear: noop,
    onChange: noop,
    isLoading: false,
    options: editorOptions.hosts,
  },
  'renders EditorHostSelect loading': {
    show: true,
    open: true,
    onToggle: noop,
    selectedItem: { id: '1', name: 'one' },
    searchQuery: '',
    onSearchChange: noop,
    onSearchClear: noop,
    onChange: noop,
    isLoading: true,
    options: editorOptions.hosts,
  },
};

describe('EditorHostSelect', () => {
  describe('should render', () =>
    testComponentSnapshotsWithFixtures(EditorHostSelect, fixtures));
});
