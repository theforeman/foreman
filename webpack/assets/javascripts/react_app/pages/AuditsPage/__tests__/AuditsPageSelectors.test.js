import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  selectAuditsPage,
  selectAudits,
  selectAuditsSelectedPage,
  selectAuditsPerPage,
  selectAuditsCount,
  selectAuditsMessage,
  selectAuditsShowMessage,
} from '../AuditsPageSelector';
import { state } from '../AuditsPage.fixtures';

const fixtures = {
  'should return auditsPage': () => selectAuditsPage(state),
  'should return Audits array': () => selectAudits(state),
  'should return selected page': () => selectAuditsSelectedPage(state),
  'should return selected perPage': () => selectAuditsPerPage(state),
  'should return Audits array count': () => selectAuditsCount(state),
  'should return Audits showMessage bool': () => selectAuditsShowMessage(state),
  'should return Audits message': () => selectAuditsMessage(state),
};

describe('AuditsPage selectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
