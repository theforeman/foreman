import SearchBar from '../SearchBar';
import { SearchBarProps } from '../SearchBar.fixtures.js';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'renders AutoComplete': SearchBarProps,
};
describe('AutoComplete', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(SearchBar, fixtures);
  });
});
