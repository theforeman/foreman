import { breadcrumbBar } from '../../../components/BreadcrumbBar/BreadcrumbBar.fixtures';
import { SearchBarProps } from '../../../components/SearchBar/SearchBar.fixtures';

export const pageLayoutMock = {
  headTags: { title: 'some title' },
  searchable: true,
  searchProps: SearchBarProps,
  customBreadcrumbs: null,
  breadcrumbOptions: breadcrumbBar,
  toolbarButtons: null,
  children: 'body',
};
