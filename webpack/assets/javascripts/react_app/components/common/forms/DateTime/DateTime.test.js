import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import { DateTimeProps, DateTimeWithRequireAndInfo } from './DateTime.fixtures';
import DateTime from './DateTime';

const fixtures = {
  'renders Report Date input': DateTimeProps,
  'renders with Require and Info': DateTimeWithRequireAndInfo,
};

describe('DateTime', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(DateTime, fixtures);
  });
});
