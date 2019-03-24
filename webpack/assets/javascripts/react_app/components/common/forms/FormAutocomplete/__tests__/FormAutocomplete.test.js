import FormAutocomplete from '../FormAutocomplete';
import { formAutocompleteDataProps } from '../FormAutocomplete.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

const fixtures = {
  'renders AutoComplete': formAutocompleteDataProps,
};
describe('AutoComplete', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(FormAutocomplete, fixtures);
  });
});
