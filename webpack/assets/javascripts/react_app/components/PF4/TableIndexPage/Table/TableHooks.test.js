import { act, renderHook } from '@testing-library/react-hooks';
import { useLocation } from 'react-router-dom';
import { friendlySearchParam, useBulkSelect, useUrlParams } from './TableHooks';

jest.mock('react-router-dom', () => ({
  useLocation: jest.fn(),
}));

const mockUseLocation = useLocation;

const isSelectable = () => true;
const idColumn = 'errata_id';
const metadata = {
  error: null, selectable: 2, subtotal: 2, total: 2,
};
const results = [
  {
    errata_id: 'RHSA-2022:2031',
    id: 311,
    severity: 'Low',
    type: 'security',
  },
  {
    errata_id: 'RHSA-2022:2110',
    id: 17,
    severity: 'Low',
    type: 'security',
  },
];

it('returns a scoped search string based on inclusionSet', () => {
  const { result } = renderHook(() => useBulkSelect({
    results,
    metadata,
    idColumn,
    isSelectable,
  }));

  act(() => {
    result.current.selectOne(true, 'RHSA-2022:2031');
  });

  expect(result.current.fetchBulkParams({})).toBe('errata_id ^ (RHSA-2022:2031)');
});

it('returns a scoped search string based on exclusionSet', () => {
  const { result } = renderHook(() => useBulkSelect({
    results,
    metadata,
    idColumn,
    isSelectable,
  }));

  act(() => {
    result.current.selectAll(true);
  });

  act(() => {
    result.current.selectOne(false, 'RHSA-2022:2031');
  });

  expect(result.current.fetchBulkParams({})).toBe('errata_id !^ (RHSA-2022:2031)');
});

it('adds search query to scoped search string based on exclusionSet', () => {
  const { result } = renderHook(() => useBulkSelect({
    results,
    metadata,
    idColumn,
    isSelectable,
  }));

  act(() => {
    result.current.updateSearchQuery('type=security');
  });

  act(() => {
    result.current.selectAll(true);
  });

  act(() => {
    result.current.selectOne(false, 'RHSA-2022:2031');
  });

  expect(result.current.fetchBulkParams({})).toBe('type=security and errata_id !^ (RHSA-2022:2031)');
});

it('adds filter dropdown query to scoped search string', () => {
  const { result } = renderHook(() => useBulkSelect({
    results,
    metadata,
    idColumn,
    isSelectable,
    filtersQuery: 'severity=Low',
  }));

  act(() => {
    result.current.selectAll(true);
  });

  act(() => {
    result.current.selectOne(false, 'RHSA-2022:2031');
  });

  expect(result.current.fetchBulkParams({})).toBe('severity=Low and errata_id !^ (RHSA-2022:2031)');
});

it('normalizes + separators in friendlySearchParam', () => {
  expect(friendlySearchParam('name+~+foo/bar')).toBe('name ~ foo/bar');
});

it('keeps encoded percent fragments untouched in friendlySearchParam', () => {
  expect(friendlySearchParam('name+~+foo%2Fbar')).toBe('name ~ foo%2Fbar');
  expect(friendlySearchParam('name+~+foo%2')).toBe('name ~ foo%2');
});

it('parses hosts search query params without crashing on percent search', () => {
  mockUseLocation.mockReturnValue({
    search: '?search=%25&page=1',
  });

  const { result } = renderHook(() => useUrlParams());
  expect(result.current).toEqual({
    searchParam: '%',
    page: '1',
  });
});
