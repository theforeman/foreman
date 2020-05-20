import { mockWindowLocation } from './testHelpers';
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
  const baseHref = 'http://some-url.com/';
  const oldQuery = 'search=some-search&page=1&per_page=25&order=name+ASC';
  const href = `${baseHref}?${oldQuery}`;

  beforeEach(() => {
    mockWindowLocation({ href });
  });

  it('should resolve change-query', () => {
    const navigateToMock = jest.fn();
    const newQuery = { search: 'some-new-search', per_page: 10 };

    changeQuery(newQuery);
    expect(global.window.location.href).toEqual(
      `${baseHref}?search=some-new-search&page=1&per_page=10&order=name+ASC`
    );

    changeQuery(newQuery, navigateToMock);
    expect(navigateToMock).toHaveBeenCalledWith(
      `${baseHref}?search=some-new-search&page=1&per_page=10&order=name+ASC`
    );
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
    expect(getURIpage()).toEqual(1);
    expect(getURIperPage()).toEqual(25);
    expect(getURIsearch()).toEqual('some-search');
  });

  it('exportURL should return a valid url', () => {
    expect(exportURL()).toBe(`/?${oldQuery}&format=csv`);
  });
});
