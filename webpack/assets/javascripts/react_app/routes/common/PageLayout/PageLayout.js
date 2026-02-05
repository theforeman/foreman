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

const PageLayout = ({
  searchable,
  searchProps,
  searchQuery,
  onSearch,
  customBreadcrumbs,
  breadcrumbOptions,
  toolbarButtons,
  header,
  beforeToolbarComponent,
  isLoading,
  pageSectionType,
  children,
}) => {
  const title = (
    <TextContent>
      <Text ouiaId="breadcrumb_title" component="h1">
        {header}
      </Text>
    </TextContent>
  );

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

      {(searchable || !toolbarButtons) && (
        <PageSection variant={PageSectionVariants.light} type="breadcrumb">
          <div id="breadcrumb">{title}</div>
        </PageSection>
      )}

      {(searchable ||
        beforeToolbarComponent ||
        isLoading ||
        toolbarButtons) && (
        <PageSection
          variant={PageSectionVariants.light}
          className="page-toolbar-section"
        >
          {beforeToolbarComponent}
          <Toolbar ouiaId="page-toolbar">
            <ToolbarContent>
              <ToolbarItem widths={{ default: '50%' }}>
                {!searchable && toolbarButtons && title}
                {searchable && (
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
                )}
              </ToolbarItem>
              {isLoading && (
                <ToolbarItem alignSelf="center" id="toolbar-spinner">
                  <Spinner size="md" />
                </ToolbarItem>
              )}
              <ToolbarGroup align={{ default: 'alignRight' }}>
                {toolbarButtons}
              </ToolbarGroup>
            </ToolbarContent>
          </Toolbar>
        </PageSection>
      )}
      <PageSection variant={PageSectionVariants.light} type={pageSectionType}>
        {children}
      </PageSection>
    </>
  );
};

PageLayout.propTypes = {
  children: PropTypes.node.isRequired,
  searchable: PropTypes.bool.isRequired,
  header: PropTypes.string,
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
  onSearch: PropTypes.func,
  searchQuery: PropTypes.string,
  beforeToolbarComponent: PropTypes.node,
  isLoading: PropTypes.bool,
  pageSectionType: PropTypes.string,
};

PageLayout.defaultProps = {
  searchProps: {},
  header: '',
  searchQuery: '',
  customBreadcrumbs: null,
  toolbarButtons: null,
  breadcrumbOptions: null,
  isLoading: false,
  onSearch: searchQuery => changeQuery({ search: searchQuery.trim(), page: 1 }),
  beforeToolbarComponent: null,
  pageSectionType: 'default',
};

export default PageLayout;
