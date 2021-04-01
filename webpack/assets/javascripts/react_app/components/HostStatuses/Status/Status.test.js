import Status from '../Status';
import { HOST_STATUSES_KEY } from '../HostStatusesConstants';
import { store } from '../HostStatuses.fixtures.js'
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

jest.mock('react-redux', () => ({
  useSelector: jest.fn().mockImplementation(selector => selector()),
}));

jest.mock('../HostStatusesSelectors.js', () => {
  const { get } = require('lodash');
  const { HOST_STATUSES_KEY } = require('../HostStatusesConstants')
  const { store } = require('../HostStatuses.fixtures.js');

  const status = get(store, ['API', HOST_STATUSES_KEY, 'response', 'results', '0'])
  const details = get(status, 'details')

  return {
    selectGlobalStatus: jest.fn().mockReturnValue(2),
    selectHostStatusDetails: jest.fn().mockReturnValue(details),
    selectHostStatusDescription: jest.fn().mockReturnValue(get(status, 'description')),
    selectHostStatusTotalPaths: jest.fn().mockReturnValue({
      okTotalPath: get(status, 'ok_total_path'),
      warnTotalPath: get(status, 'warn_total_path'),
      errorTotalPath: get(status, 'error_total_path'),
    }),
    selectHostStatusOwnedPaths: jest.fn().mockReturnValue({
      errorOwnedPath: get(status, 'ok_owned_path'),
      okOwnedPath: get(status, 'warn_owned_path'),
      warnOwnedPath: get(status, 'error_owned_path'),
    }),
    selectHostStatusCounter: jest.fn().mockReturnValue({
      ok: {
        "owned": details.filter(({ global_status: gs }) => gs == 0).map(({ owned }) => owned).reduce((a, b) => a + b),
        "total": details.filter(({ global_status: gs }) => gs == 0).map(({ total }) => total).reduce((a, b) => a + b),
      },
      warn: {
        "owned": details.filter(({ global_status: gs }) => gs == 1).map(({ owned }) => owned).reduce((a, b) => a + b),
        "total": details.filter(({ global_status: gs }) => gs == 1).map(({ total }) => total).reduce((a, b) => a + b),
      },
      error: {
        "owned": details.filter(({ global_status: gs }) => gs == 2).map(({ owned }) => owned).reduce((a, b) => a + b),
        "total": details.filter(({ global_status: gs }) => gs == 2).map(({ total }) => total).reduce((a, b) => a + b),
      },
      unknown: {
        "owned": details.filter(({ global_status: gs }) => gs == null).map(({ owned }) => owned).reduce((a, b) => (a + b), 0),
        "total": details.filter(({ global_status: gs }) => gs == null).map(({ total }) => total).reduce((a, b) => (a + b), 0),
      },
    }),
  }
});

const fixtures = {
  'renders Status': { name: store.API[HOST_STATUSES_KEY].response.results[0].name },
};
describe('Status', () => {
  testComponentSnapshotsWithFixtures(Status, fixtures);
});
