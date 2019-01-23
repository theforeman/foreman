import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import TemplateInput from '../TemplateInput';
import {
  ReportTemplateGenerateDate,
  ReportTemplateGenerateSearch,
} from '../Inputs/TemplateInput.fixures';

const fixtures = {
  'renders report template with date input': ReportTemplateGenerateDate,
  'renders report template with search input': ReportTemplateGenerateSearch,
};

describe('Report Template AutoComplete', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(TemplateInput, fixtures);
  });
});
