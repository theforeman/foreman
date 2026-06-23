import { AuditsProps } from '../../../../components/AuditsList/__tests__/AuditsList.fixtures';
import {
  selectAudits,
  selectAuditsCount,
  selectAuditsHasData,
  selectAuditsHasError,
  selectAuditsIsLoadingPage,
  selectAuditsMessage,
  selectAuditsPerPage,
  selectAuditsSearch,
  selectAuditsSelectedPage,
} from '../AuditsPageSelectors';
import { state } from '../AuditsPage.fixtures';

describe('AuditsPage selectors', () => {
  it('should return Audits array', () => {
    expect(selectAudits(state)).toEqual(AuditsProps.audits);
  });

  it('should return selected page', () => {
    expect(selectAuditsSelectedPage(state)).toBe(1);
  });

  it('should return selected perPage', () => {
    expect(selectAuditsPerPage(state)).toBe(20);
  });

  it('should return Audits array count', () => {
    expect(selectAuditsCount(state)).toBe(0);
  });

  it('should return Audits hasError bool', () => {
    expect(selectAuditsHasError(state)).toBe(false);
  });

  it('should return Audits hasData bool', () => {
    expect(selectAuditsHasData(state)).toBe(true);
  });

  it('should return Audits message', () => {
    expect(selectAuditsMessage(state)).toBe('');
  });

  it('should return Audits Search Value', () => {
    expect(selectAuditsSearch(state)).toBe('');
  });

  it('should return Audits isLoading bool', () => {
    expect(selectAuditsIsLoadingPage(state)).toBe(false);
  });
});
