import React from 'react';
import PropTypes from 'prop-types';
import { Col, Spinner } from 'patternfly-react';
import {
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
}) => (
  <>
    <Head>
      <title>{header}</title>
    </Head>
    <PageSection variant={PageSectionVariants.light} type="breadcrumb">
      <div id="breadcrumb">
        {!breadcrumbOptions && (
          <TextContent>
            <Text component="h1">{header}</Text>
          </TextContent>
        )}
        {customBreadcrumbs ||
          (breadcrumbOptions && <BreadcrumbBar {...breadcrumbOptions} />)}
      </div>
    </PageSection>

    {(searchable || beforeToolbarComponent || isLoading || toolbarButtons) && (
      <PageSection variant={PageSectionVariants.light}>
        {beforeToolbarComponent}
        <div className="title_filter_parent">
          <Col className="title_filter" md={searchable ? 6 : 4}>
            {searchable && (
              <SearchBar
                data={{
                  ...searchProps,
                  autocomplete: { ...searchProps.autocomplete, searchQuery },
                }}
                onSearch={onSearch}
              />
            )}
          </Col>
          <Col md={searchable ? 6 : 8}>
            <div className="btn-toolbar pull-right">
              {isLoading && (
                <div id="toolbar-spinner">
                  <Spinner loading size="sm" />
                </div>
              )}
              {toolbarButtons}
            </div>
          </Col>
        </div>
      </PageSection>
    )}
    <PageSection variant={PageSectionVariants.light} type={pageSectionType}>
      {children}
    </PageSection>
  </>
);

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
