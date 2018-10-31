import { getURI, changeQuery } from './PaginationHelper';

describe('PaginationHelper', () => {
  it('should not reset search when set the per_page param', () => {
    const uri = getURI();
    let changePerPage = changeQuery(uri, { search: 'blue' }, () => {});
    expect(changePerPage).toBe('http://localhost/?search=blue');
    changePerPage = changeQuery(uri, { per_page: 5 }, () => {});
    expect(changePerPage).toBe('http://localhost/?search=blue&per_page=5');
  });

  it('should reset page to 1 when set the per_page param', () => {
    const uri = getURI();
    let changePerPage = changeQuery(uri, { page: 3 }, () => {});
    expect(changePerPage).toBe('http://localhost/?page=3');
    changePerPage = changeQuery(uri, { per_page: 5, page: 1 }, () => {});
    expect(changePerPage).toBe('http://localhost/?page=1&per_page=5');
  });
});
