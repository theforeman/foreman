import { testSelectorsSnapshotWithFixtures } from '../../../../common/testHelpers';
import {
  selectAuditsPage,
  selectNextPageAudits,
  selectPrevPageAudits,
  selectAudits,
  selectAuditsSelectedPage,
  selectAuditsPerPage,
  selectAuditsCount,
  selectAuditsMessage,
  selectAuditsShowMessage,
  selectAuditsIsLoading,
  selectAuditsSearch,
  selectAuditsIsFetchingNext,
  selectAuditsIsFetchingPrev,
} from '../AuditsPageSelector';
import { state } from '../AuditsPage.fixtures';

const fixtures = {
  'should return auditsPage': () => selectAuditsPage(state),
  'should return Audits array': () => selectAudits(state),
  'should return Next Page Audits array': () => selectNextPageAudits(state),
  'should return Prev Page Audits array': () => selectPrevPageAudits(state),
  'should return selected page': () => selectAuditsSelectedPage(state),
  'should return selected perPage': () => selectAuditsPerPage(state),
  'should return Audits array count': () => selectAuditsCount(state),
  'should return Audits showMessage bool': () => selectAuditsShowMessage(state),
  'should return Audits message': () => selectAuditsMessage(state),
  'should return Audits Search Value': () => selectAuditsSearch(state),
  'should return Audits isLoading bool': () => selectAuditsIsLoading(state),
  'should return Audits isFetchingNext': () =>
    selectAuditsIsFetchingNext(state),
  'should return Audits isFetchingPrev': () =>
    selectAuditsIsFetchingPrev(state),
};

describe('AuditsPage selectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
