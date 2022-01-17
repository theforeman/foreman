import { deprecate } from '../../common/DeprecationService';

export default () => {
  deprecate(
    'PF3 Pagination',
    'PF4 pagination from "react_app/components/Pagination/index.js"',
    3.2
  );
};
