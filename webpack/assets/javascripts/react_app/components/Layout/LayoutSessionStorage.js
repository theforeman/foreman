import { getValue } from '../../common/SessionStorage';

export const getIsNavbarCollapsed = () =>
  !!getValue(`["navCollapsed","pinnedPath"]`)?.navCollapsed;
