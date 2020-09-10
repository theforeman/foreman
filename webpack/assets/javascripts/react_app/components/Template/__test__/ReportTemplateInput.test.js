import TemplateInput from '../TemplateInput';
import {
  ReportTemplateGenerateDate,
  ReportTemplateGenerateSearch,
} from '../Inputs/TemplateInput.fixures';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'renders report template with date input': ReportTemplateGenerateDate,
  'renders report template with search input': ReportTemplateGenerateSearch,
};

describe('Report Template AutoComplete', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(TemplateInput, fixtures);
  });
});
