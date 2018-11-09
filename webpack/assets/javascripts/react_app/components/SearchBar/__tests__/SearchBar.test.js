import SearchBar from '../SearchBar';
import { SearchBarProps } from '../SearchBar.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'renders AutoComplete': SearchBarProps,
};
describe('AutoComplete', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(SearchBar, fixtures);
  });
});
