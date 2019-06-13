import { testSelectorsSnapshotWithFixtures } from '../../../../common/testHelpers';
import {
  selectAudits,
  selectAuditsSelectedPage,
  selectAuditsPerPage,
  selectAuditsCount,
  selectAuditsMessage,
  selectAuditsHasData,
  selectAuditsHasError,
  selectAuditsSearch,
} from '../AuditsPageSelectors';
import { state } from '../AuditsPage.fixtures';

const fixtures = {
  'should return Audits array': () => selectAudits(state),
  'should return selected page': () => selectAuditsSelectedPage(state),
  'should return selected perPage': () => selectAuditsPerPage(state),
  'should return Audits array count': () => selectAuditsCount(state),
  'should return Audits hasError bool': () => selectAuditsHasError(state),
  'should return Audits hasData bool': () => selectAuditsHasData(state),
  'should return Audits message': () => selectAuditsMessage(state),
  'should return Audits Search Value': () => selectAuditsSearch(state),
};

describe('AuditsPage selectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
