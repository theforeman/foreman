import { testComponentSnapshotsWithFixtures } from '../../common/testHelpers';
import Pagination from '../Pagination/Pagination';
import { paginationMock } from './Pagination.fixtures';


const fixtures = {
  'renders layout': paginationMock,
};

describe('Pagination', () => {
  describe('rendering', () => testComponentSnapshotsWithFixtures(Pagination, fixtures));
});

