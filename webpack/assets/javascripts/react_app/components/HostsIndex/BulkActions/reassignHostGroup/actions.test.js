import { APIActions } from '../../../../redux/API';
import { fetchHostgroups, HOSTGROUP_KEY } from './actions';

jest.mock('../../../../redux/API', () => ({
  APIActions: {
    get: jest.fn(params => params),
  },
}));

jest.mock('../../../../common/helpers', () => ({
  foremanUrl: jest.fn(path => path),
}));

test('fetches only the host group fields needed by the selector', () => {
  fetchHostgroups();

  expect(APIActions.get).toHaveBeenCalledWith({
    key: HOSTGROUP_KEY,
    url: '/api/v2/hostgroups',
    params: {
      per_page: 'all',
      thin: true,
    },
  });
});
