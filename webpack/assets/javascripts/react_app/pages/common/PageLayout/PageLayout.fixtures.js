import { breadcrumbBar } from '../../../components/BreadcrumbBar/BreadcrumbBar.fixtures';
import { SearchBarProps } from '../../../components/SearchBar/SearchBar.fixtures';

export const pageLayoutMock = {
  header: 'Page',
  searchable: true,
  searchProps: SearchBarProps,
  customBreadcrumbs: null,
  breadcrumbOptions: breadcrumbBar,
  toolbarButtons: null,
  toastNotifications: null,
  children: 'body',
};
