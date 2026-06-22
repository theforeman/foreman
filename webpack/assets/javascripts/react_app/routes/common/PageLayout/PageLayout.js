import React from 'react';
import PropTypes from 'prop-types';
import {
  Spinner,
  Toolbar,
  ToolbarContent,
  ToolbarGroup,
  ToolbarItem,
  PageSection,
  PageSectionVariants,
  TextContent,
  Text,
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
    <TextContent>
      <Text ouiaId="breadcrumb_title" component="h1">
        {header}
      </Text>
    </TextContent>
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
        <PageSection variant={PageSectionVariants.light} type="breadcrumb">
          <div id="breadcrumb">
            {customBreadcrumbs ||
              (breadcrumbOptions && <BreadcrumbBar {...breadcrumbOptions} />)}
          </div>
        </PageSection>
      )}

      {showStandaloneTitleSection && (
        <PageSection
          variant={PageSectionVariants.light}
          className="page-layout-title-section"
        >
          <div id="page-title">{titleSectionBody}</div>
        </PageSection>
      )}

      {beforeToolbarComponent}

      {showToolbarSection && (
        <PageSection
          variant={PageSectionVariants.light}
          className="page-layout-toolbar-section"
        >
          {customToolbar || (
            <Toolbar ouiaId="page-toolbar" className="page-layout-toolbar">
              <ToolbarContent>
                <ToolbarGroup
                  className="page-layout-toolbar-group-search"
                  variant="filter-group"
                >
                  {!searchable && toolbarButtons && titleSectionBody}
                  {searchable && (
                    <ToolbarItem className="page-layout-toolbar-search">
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
                <ToolbarGroup align={{ default: 'alignRight' }}>
                  {toolbarButtons}
                </ToolbarGroup>
              </ToolbarContent>
            </Toolbar>
          )}
        </PageSection>
      )}
      <PageSection
        className="page-layout-content-section"
        variant={PageSectionVariants.light}
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
