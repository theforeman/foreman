import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import {
  dateTimeWithErrorProps,
  textFieldWithHelpProps,
  formAutocompleteDataProps,
} from '../FormField.fixtures';
import FormField from '../FormField';

const fixtures = {
  'renders text input': { type: 'text', name: 'a' },
  'renders Date input': { type: 'date', name: 'a' },
  'renders Time input': { type: 'time', name: 'a' },
  'renders DateTime input': { type: 'dateTime', name: 'a' },
  'renders text complex options and help': textFieldWithHelpProps,
  'renders DateTime complex options and error': dateTimeWithErrorProps,
  'renders AutoComplete': { type: 'autocomplete', formAutocompleteDataProps },
};

describe('FormField', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(FormField, fixtures);
  });
});
