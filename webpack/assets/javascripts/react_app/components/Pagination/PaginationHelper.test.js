import { getURI, changeQuery } from './PaginationHelper';

describe('PaginationHelper', () => {
  it('should not reset search when set the per_page param', () => {
    const uri = getURI();
    let changePerPage = changeQuery(uri, { search: 'blue' }, () => {});
    expect(changePerPage).toBe('http://localhost/?search=blue');
    changePerPage = changeQuery(uri, { per_page: 5 }, () => {});
    expect(changePerPage).toBe('http://localhost/?search=blue&per_page=5');
  });
});
