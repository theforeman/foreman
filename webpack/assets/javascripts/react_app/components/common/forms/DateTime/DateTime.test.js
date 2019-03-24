import DateTime from './DateTime';
import {
  ReportDateTimePrpos,
  ReportDateTimeWithRequireAndInfo,
} from '../../../Template/Inputs/TemplateInput.fixures';
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

const fixtures = {
  'renders Report Date input': ReportDateTimePrpos,
  'With Require and Info': ReportDateTimeWithRequireAndInfo,
};

describe('Report Template AutoComplete', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(DateTime, fixtures);
  });
});
