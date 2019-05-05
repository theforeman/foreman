import { urlBuilder, urlWithSearch } from './urlHelpers';

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
