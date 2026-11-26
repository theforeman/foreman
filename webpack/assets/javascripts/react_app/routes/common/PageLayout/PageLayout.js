import React from 'react';
import PropTypes from 'prop-types';
import {
  Spinner,
  Toolbar,
  ToolbarContent,
  ToolbarGroup,
  ToolbarItem,
  PageSection,
  Content,
} from '@patternfly/react-core';
import { changeQuery } from '../../../common/urlHelpers';
import BreadcrumbBar from '../../../components/BreadcrumbBar';
import SearchBar from '../../../components/SearchBar';
import Head from '../../../components/Head';
import './PageLayout.scss';

const PageLayout = ({
  searchable,
  searchProps,
  searchQuery,
  onSearch,
  customBreadcrumbs,
  breadcrumbOptions,
  toolbarButtons,
  customToolbar,
  header,
  customHeader,
  beforeToolbarComponent,
  isLoading,
  pageSectionType,
  children,
}) => {
  const titleSectionBody = customHeader ?? (
    <Content>
      <Content ouiaId="breadcrumb_title" component="h1">
        {header}
      </Content>
    </Content>
  );

  const showStandaloneTitleSection = searchable || !toolbarButtons;

  const toolbarSectionShowsDefaultToolbar =
    !customToolbar && (searchable || isLoading || toolbarButtons);

  const showToolbarSection =
    toolbarSectionShowsDefaultToolbar || Boolean(customToolbar);

  return (
    <>
      <Head>
        <title>{header}</title>
      </Head>

      {(customBreadcrumbs || breadcrumbOptions) && (
        <PageSection hasBodyWrapper={false} type="breadcrumb">
          <div id="breadcrumb">
            {customBreadcrumbs ||
              (breadcrumbOptions && (
                <BreadcrumbBar {...breadcrumbOptions} isPf4 />
              ))}
          </div>
        </PageSection>
      )}

      {showStandaloneTitleSection && (
        <PageSection hasBodyWrapper={false} id="page-layout-title-section">
          <div id="page-title">{titleSectionBody}</div>
        </PageSection>
      )}

      {beforeToolbarComponent}

      {showToolbarSection && (
        <PageSection hasBodyWrapper={false} id="page-layout-toolbar-section">
          {customToolbar || (
            <Toolbar
              ouiaId="page-toolbar"
              className="page-toolbar"
              id="page-layout-toolbar"
            >
              <ToolbarContent>
                <ToolbarGroup
                  className="page-layout-toolbar-group-search"
                  variant="filter-group"
                  flexGrow={{ default: 'flexGrow' }}
                >
                  {!searchable && toolbarButtons && titleSectionBody}
                  {searchable && (
                    <ToolbarItem
                      id="page-layout-toolbar-search"
                      flexGrow={{ default: 'flexGrow' }}
                    >
                      <SearchBar
                        data={{
                          ...searchProps,
                          autocomplete: {
                            ...searchProps.autocomplete,
                            searchQuery,
                          },
                        }}
                        onSearch={onSearch}
                      />
                    </ToolbarItem>
                  )}
                  {isLoading && (
                    <ToolbarItem alignSelf="center" id="toolbar-spinner">
                      <Spinner size="md" />
                    </ToolbarItem>
                  )}
                </ToolbarGroup>
                <ToolbarGroup
                  align={{ default: 'alignEnd' }}
                  flexGrow={{ default: 'flexGrow' }}
                >
                  {toolbarButtons}
                </ToolbarGroup>
              </ToolbarContent>
            </Toolbar>
          )}
        </PageSection>
      )}
      <PageSection
        hasBodyWrapper={false}
        id="page-layout-content-section"
        type={pageSectionType}
      >
        {children}
      </PageSection>
    </>
  );
};

PageLayout.propTypes = {
  children: PropTypes.node.isRequired,
  searchable: PropTypes.bool.isRequired,
  searchProps: PropTypes.shape({
    autocomplete: PropTypes.shape({
      results: PropTypes.array,
      searchQuery: PropTypes.string,
      url: PropTypes.string,
      useKeyShortcuts: PropTypes.bool,
    }),
    controller: PropTypes.string,
    bookmarks: PropTypes.shape({
      text: PropTypes.string,
      query: PropTypes.string,
    }),
  }),
  customBreadcrumbs: PropTypes.node,
  breadcrumbOptions: PropTypes.shape({
    isSwitchable: PropTypes.bool,
    resource: PropTypes.shape({
      nameField: PropTypes.string,
      resourceUrl: PropTypes.string,
      switcherItemUrl: PropTypes.string,
      resourceFilter: PropTypes.string,
    }),
    breadcrumbItems: PropTypes.arrayOf(
      PropTypes.shape({
        caption: PropTypes.oneOfType([
          PropTypes.string.isRequired,
          PropTypes.shape({
            icon: PropTypes.shape({
              url: PropTypes.string,
              alt: PropTypes.string,
            }),
            text: PropTypes.string,
          }),
        ]),
        url: PropTypes.string,
      })
    ),
  }),
  toolbarButtons: PropTypes.node,
  customToolbar: PropTypes.node,
  header: PropTypes.string,
  customHeader: PropTypes.node,
  onSearch: PropTypes.func,
  searchQuery: PropTypes.string,
  beforeToolbarComponent: PropTypes.node,
  isLoading: PropTypes.bool,
  pageSectionType: PropTypes.string,
};

PageLayout.defaultProps = {
  searchProps: {},
  header: '',
  customHeader: null,
  searchQuery: '',
  customBreadcrumbs: null,
  toolbarButtons: null,
  customToolbar: null,
  breadcrumbOptions: null,
  isLoading: false,
  onSearch: newSearch => changeQuery({ search: newSearch.trim(), page: 1 }),
  beforeToolbarComponent: null,
  pageSectionType: 'default',
};

export default PageLayout;
