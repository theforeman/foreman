import { deprecate } from '../../common/DeprecationService';

export default () => {
  deprecate(
    'PaginationWrapper',
    'PF4 pagination from "react_app/components/Pagination/index.js"',
    3.2
  );
};
