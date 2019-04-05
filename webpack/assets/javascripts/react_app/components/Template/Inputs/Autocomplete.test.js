import Autocomplete from './AutoComplete';
import {
  ReportAutocompleteWithRequireAndInfo,
  ReportAutocompleteProps,
} from './TemplateInput.fixures';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'renders ReportAutoComplete': ReportAutocompleteProps,
  'With Require and Descriptions': ReportAutocompleteWithRequireAndInfo,
};

describe('Report Template AutoComplete', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(Autocomplete, fixtures);
  });
});
