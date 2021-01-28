import { usePaginationOptions } from './PaginationHooks';
import * as helpers from '../../common/urlHelpers';

describe('Pagination Hooks', () => {
  it('should render pagination options', () => {
    expect(usePaginationOptions()).toMatchSnapshot();
  });
  it('should add per_page query to pagination options and sort it', () => {
    helpers.getURIperPage = jest.fn().mockImplementation(() => 3);
    expect(usePaginationOptions()).toMatchSnapshot();
  });
});
