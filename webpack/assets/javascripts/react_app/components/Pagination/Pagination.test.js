import { testComponentSnapshotsWithFixtures } from '../../common/testHelpers';
import Pagination from '../Pagination/Pagination';
import PaginationWrapper from '../Pagination/PaginationWrapper';

import { paginationMock } from './Pagination.fixtures';

const fixtures = {
  'renders layout': paginationMock,
};

const getBaseProps = () => ({
  pagination: {
    page: 2,
    perPage: 20,
    perPageOptions: [5, 10, 25],
  },
  itemCount: 52,
  viewType: 'list',
});

describe('Pagination', () => {
  describe('rendering from erb', () =>
    testComponentSnapshotsWithFixtures(Pagination, fixtures));

  describe('rendering from js', () =>
    testComponentSnapshotsWithFixtures(PaginationWrapper, {
      'renders correctly': getBaseProps(),
    }));
});
