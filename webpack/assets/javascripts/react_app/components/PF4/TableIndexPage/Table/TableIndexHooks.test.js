import { renderHook } from '@testing-library/react-hooks';
import { useAPI } from '../../../../common/hooks/API/APIHooks';
import { STATUS } from '../../../../constants';
import { useCurrentUserTablePreferences } from './TableIndexHooks';

jest.mock('../../../../common/hooks/API/APIHooks', () => ({
  useAPI: jest.fn(),
}));

const mockPreferences = (currentUser, preferences) => {
  useAPI.mockImplementation((method, url) => {
    if (url === '/api/v2/current_user') return currentUser;
    return preferences;
  });
};

describe('useCurrentUserTablePreferences', () => {
  test('loads the collection and selects the named table', () => {
    mockPreferences(
      { response: { id: 4 }, status: STATUS.RESOLVED },
      {
        response: {
          results: [
            { name: 'other', columns: ['a'] },
            { name: 'hosts', columns: ['name', 'os_title'] },
          ],
        },
        status: STATUS.RESOLVED,
      }
    );

    const { result } = renderHook(() =>
      useCurrentUserTablePreferences({ tableName: 'hosts' })
    );

    expect(useAPI).toHaveBeenCalledWith(
      'get',
      '/api/v2/users/4/table_preferences',
      { params: { per_page: 'all' } }
    );
    expect(result.current).toEqual({
      currentUserId: 4,
      hasPreference: true,
      columns: ['name', 'os_title'],
    });
  });

  test('reports no preference when the collection has no matching row', () => {
    mockPreferences(
      { response: { id: 4 }, status: STATUS.RESOLVED },
      { response: { results: [] }, status: STATUS.RESOLVED }
    );

    const { result } = renderHook(() =>
      useCurrentUserTablePreferences({ tableName: 'hosts' })
    );

    expect(result.current).toEqual({
      currentUserId: 4,
      hasPreference: false,
      columns: undefined,
    });
  });

  test('keeps hasPreference true until the collection resolves', () => {
    mockPreferences(
      { response: { id: 4 }, status: STATUS.RESOLVED },
      { response: undefined, status: STATUS.PENDING }
    );

    const { result } = renderHook(() =>
      useCurrentUserTablePreferences({ tableName: 'hosts' })
    );

    expect(result.current.hasPreference).toBe(true);
    expect(result.current.columns).toBeUndefined();
  });

  test('does not request preferences before the current user id is known', () => {
    mockPreferences(
      { response: undefined, status: STATUS.PENDING },
      { response: undefined, status: undefined }
    );

    renderHook(() => useCurrentUserTablePreferences({ tableName: 'hosts' }));

    expect(useAPI).toHaveBeenCalledWith(null, null, {
      params: { per_page: 'all' },
    });
  });
});
