import { STATUS } from '../../../constants';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import InvalidateUserJwt from '../InvalidateUserJwt';

const baseFixtures = {
  isModalOpen: false,
  handleModal: () => {},
  handleSubmit: () => {},
  apiStatus: undefined,
  isLoading: false
}
const fixtures = {
  'renders': baseFixtures,
  'pending': {...baseFixtures, apiStatus: STATUS.PENDING, isLoading: true},
  'success': {...baseFixtures, apiStatus: STATUS.RESOLVED},
  'error': {...baseFixtures, apiStatus: STATUS.ERROR},
};

describe('InvalidateUserJwt', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(InvalidateUserJwt, fixtures));
  });
