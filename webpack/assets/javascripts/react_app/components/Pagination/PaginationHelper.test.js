import { Paginator } from 'patternfly-react';
import { getURI, translatePagination, changeQuery } from './PaginationHelper';

describe('PaginationHelper', () => {
  it('translatePagination', () => {
    const translated = translatePagination(Paginator.defaultProps.messages);
    expect(translated).toMatchSnapshot();
  });

  it('should not reset search when set the per_page param', () => {
    const uri = getURI();
    let changePerPage = changeQuery(uri, { search: 'blue' }, () => {});
    expect(changePerPage).toBe('about:blank?search=blue');
    changePerPage = changeQuery(uri, { per_page: 5 }, () => {});
    expect(changePerPage).toBe('about:blank?search=blue&per_page=5');
  });
});

