import store from './react_app/redux';

import { updateBreadcrumbTitle } from './react_app/components/BreadcrumbBar/BreadcrumbBarActions';

export const updateTitle = title =>
  store.dispatch(updateBreadcrumbTitle(title));
