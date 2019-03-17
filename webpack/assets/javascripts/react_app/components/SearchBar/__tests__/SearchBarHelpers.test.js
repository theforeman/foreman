import { resolveSearchQuery } from '../SearchBarHelpers';

const mockWindow = ({ href, visit }) => {
  const windowLocation = JSON.stringify(window.location);
  delete window.location;
  Object.defineProperty(window, 'location', {
    value: JSON.parse(windowLocation),
  });

  window.location.href = href;
  window.Turbolinks = { visit };
};

describe('SearchBar helpers', () => {
  test('should resolve search-query', () => {
    const visit = jest.fn();
    const baseHref = 'http://some-url.com/';
    const oldQuery = 'search=some-search&page=3&field=val';
    const href = `${baseHref}?${oldQuery}`;
    mockWindow({ href, visit });

    const searchQuery = 'some-new-search';
    resolveSearchQuery(searchQuery);

    expect(visit).toBeCalledWith(
      `${baseHref}?search=some-new-search&page=1&field=val`
    );
  });
});
