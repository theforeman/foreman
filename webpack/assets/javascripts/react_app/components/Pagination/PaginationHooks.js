import { deprecate } from '../../common/DeprecationService';

export const usePaginationOptions = () => {
  deprecate(
    'usePaginationOptions',
    'PF4 pagination which is already shipped with those options',
    3.2
  );
};
