import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Spinner } from 'patternfly-react';
import { updateDocumentTitle } from '../../../common/document';
import { changeQuery } from '../../../common/urlHelpers';

import ToastsList from '../../../components/ToastsList';
import BreadcrumbBar from '../../../components/BreadcrumbBar';
import SearchBar from '../../../components/SearchBar';

const PageLayout = ({
  header,
  searchable,
  searchProps,
  searchQuery,
  onSearch,
  onBookmarkClick,
  customBreadcrumbs,
  breadcrumbOptions,
  toolbarButtons,
  toastNotifications,
  beforeToolbarComponent,
  isLoading,
  children,
}) => {
  updateDocumentTitle(header);
  return (
    <div id="main">
      <div id="react-content">
        <ToastsList railsMessages={toastNotifications} />
        <div id="breadcrumb">
          {!breadcrumbOptions && (
            <div className="row form-group">
              <h1 className="col-md-8">{header}</h1>
            </div>
          )}
          {customBreadcrumbs
            ? { customBreadcrumbs }
            : breadcrumbOptions && <BreadcrumbBar data={breadcrumbOptions} />}
        </div>
        {beforeToolbarComponent}
        <Row>
          <Col className="title_filter" md={searchable ? 6 : 4}>
            {searchable && (
              <SearchBar
                data={searchProps}
                initialQuery={searchQuery}
                onSearch={onSearch}
                onBookmarkClick={onBookmarkClick}
              />
            )}
            &nbsp;
          </Col>
          <Col id="title_action" md={searchable ? 6 : 8}>
            <div className="btn-toolbar pull-right">
              {isLoading && (
                <div id="toolbar-spinner">
                  <Spinner loading size="sm" />
                </div>
              )}
              {toolbarButtons}
            </div>
          </Col>
        </Row>
        {children}
      </div>
    </div>
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
  toastNotifications: PropTypes.array,
  onSearch: PropTypes.func,
  onBookmarkClick: PropTypes.func,
  searchQuery: PropTypes.string,
  beforeToolbarComponent: PropTypes.node,
  isLoading: PropTypes.bool,
};

PageLayout.defaultProps = {
  searchProps: {},
  header: '',
  searchQuery: '',
  toastNotifications: [],
  customBreadcrumbs: null,
  toolbarButtons: null,
  breadcrumbOptions: null,
  isLoading: false,
  onSearch: searchQuery => changeQuery({ search: searchQuery.trim(), page: 1 }),
  onBookmarkClick: searchQuery =>
    changeQuery({ search: searchQuery.trim(), page: 1 }),
  beforeToolbarComponent: null,
};

export default PageLayout;
