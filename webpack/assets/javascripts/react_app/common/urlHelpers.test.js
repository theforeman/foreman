import {
  urlBuilder,
  urlWithSearch,
  changeQuery,
  stringifyParams,
  getParams,
  getURIpage,
  getURIperPage,
  getURIsearch,
  exportURL,
} from './urlHelpers';

const mockWindow = ({ href, visit }) => {
  const windowLocation = JSON.stringify(window.location);
  delete window.location;
  Object.defineProperty(window, 'location', {
    value: JSON.parse(windowLocation),
  });

  window.location.href = href;
  window.Turbolinks = { visit };
};

describe('urlBuilder', () => {
  const controller = 'testController';
  const action = 'testAction';
  it('builds url with id', () => {
    expect(urlBuilder(controller, action, 'testID')).toBe(
      '/testController/testID/testAction'
    );
  });

  it('builds url without id', () => {
    expect(urlBuilder(controller, action)).toBe('/testController/testAction');
  });
});

describe('urlWithSearch', () => {
  const base = 'testBase';
  const query = 'query=test';
  it('builds url with search', () => {
    expect(urlWithSearch(base, query)).toBe('/testBase?search=query=test');
  });
});

describe('URI query and stringify tests', () => {
  const visit = jest.fn();
  const baseHref = 'http://some-url.com/';
  const oldQuery = 'search=some-search&page=1&per_page=25';
  const href = `${baseHref}?${oldQuery}`;

  it('should resolve change-query', () => {
    mockWindow({ href, visit });
    const navigateToMock = jest.fn();
    const newQuery = { search: 'some-new-search', per_page: 10 };

    changeQuery(newQuery);
    expect(visit).toBeCalledWith(
      `${baseHref}?search=some-new-search&page=1&per_page=10`
    );

    changeQuery(newQuery, navigateToMock);
    expect(navigateToMock).toHaveBeenCalled();
  });

  it('should return stringified params', () => {
    const params = { page: 1, perPage: 21 };
    const stringified = stringifyParams(params);
    const stringifiedWithSearch = stringifyParams({
      ...params,
      searchQuery: 'search',
    });
    expect(stringified).toMatchSnapshot('stringify params');
    expect(stringifiedWithSearch).toMatchSnapshot('stringify params w/search');
  });

  it('should test params functions', () => {
    expect(getParams()).toMatchSnapshot('getParams');
    expect(getURIpage()).toMatchSnapshot('getPage');
    expect(getURIperPage()).toMatchSnapshot('getPerPage');
    expect(getURIsearch()).toMatchSnapshot('getSearchQuery');
  });

  it('exportURL should return a valid url', () => {
    expect(exportURL()).toBe(`/?${oldQuery}.csv`);
  });
});
