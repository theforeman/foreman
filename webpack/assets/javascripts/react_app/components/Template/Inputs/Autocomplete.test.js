import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import Autocomplete from './AutoComplete';
import {
  ReportAutocompleteWithRequireAndInfo,
  ReportAutocompleteProps,
} from './TemplateInput.fixures';

const fixtures = {
  'renders ReportAutoComplete': ReportAutocompleteProps,
  'With Require and Descriptions': ReportAutocompleteWithRequireAndInfo,
};

describe('Report Template AutoComplete', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(Autocomplete, fixtures);
  });
});
