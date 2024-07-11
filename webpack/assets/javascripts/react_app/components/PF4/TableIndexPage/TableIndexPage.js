/* eslint-disable max-lines */
import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { QuestionCircleIcon } from '@patternfly/react-icons';
import { useHistory } from 'react-router-dom';
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
  PaginationVariant,
} from '@patternfly/react-core';

import {
  createURL,
  exportURL,
  helpURL,
  getURIsearch,
} from '../../../common/urlHelpers';
import { translate as __ } from '../../../common/I18n';
import { noop } from '../../../common/helpers';
import Pagination from '../../Pagination';
import { getControllerSearchProps, STATUS } from '../../../constants';
import BreadcrumbBar from '../../BreadcrumbBar';
import SearchBar from '../../SearchBar';
import Head from '../../Head';
import { ActionButtons } from './ActionButtons';
import './TableIndexPage.scss';
import { Table } from './Table/Table';
import {
  useSetParamsAndApiAndSearch,
  useTableIndexAPIResponse,
} from './Table/TableIndexHooks';
/**

A page component that displays a table with data fetched from the API. It provides search and filtering functionality, and the ability to create new entries and export data.
@param {Object}{apiOptions} - options object for API requests. See APIRequest.js for more details
@param {string}{apiUrl} - url for the API to make requests to
@param {React.Component} {beforeToolbarComponent} - a component to be rendered before the toolbar
@param {Object} {breadcrumbOptions} - props to send to the breadcrumb bar
@param {React.ReactNode} {children} - optional children to be rendered inside the page instead of the table
@param {Object}{columns} - Not needed when passing children. An object of objects representing the columns to be displayed in the table, keys should be the same as in the api response
@param {string} columns[].title - the title of the column, translated
@param {function} columns[].wrapper - a function that returns a React component to be rendered in the column
@param {boolean} columns[].isSorted - whether or not the column is sorted
@param {string}{controller} - the name of the controller for the API
@param {boolean} {creatable} - whether or not to show create button
@param {Array<Object>} {customActionButtons} - an array of custom action buttons to be displayed in the toolbar
@param {function} {customCreateAction} - a custom action for the create new button
@param {string} {customExportURL} - a custom URL for the export button
@param {string} {customHelpURL} - a custom URL for the documentation button
@param {Object} {customSearchProps} custom search props to send to the search bar
@param {Array<Object>} {customToolbarItems} - an array of custom toolbar items to be displayed
@param {boolean} {exportable} - whether or not to show export button
@param {boolean} {hasHelpPage} - whether or not to show documentation button
@param {React.ReactNode}{customHeader} - a custom header to be rendered instead of the default header
@param {string}{headerText} - DEPRECATED - the header text for the page
@param {string}{header} -the header text for the page and the title
@param {boolean} {isDeleteable} - whether or not entries can be deleted
@param {boolean} {searchable} - whether or not the table can be searched
@param {React.ReactNode} {selectionToolbar} - Pass in the SelectAll toolbar, if desired
@param {Object} {replacementResponse} - If included, skip the API request and use this response instead
@param {boolean} {showCheckboxes} - Not needed when passing children. Whether or not to show selection checkboxes in the first column.
@param {function} {rowSelectTd} - Not needed when passing children. A function that takes a single result object and returns a React component to be rendered in the first column.
@param {function} {selectOne} - Not needed when passing children. Pass in the selectOne function from useBulkSelect, to use within rowSelectTd.
@param {function} {isSelected} - Not needed when passing children. Pass in the isSelected function from useBulkSelect, to use within rowSelectTd.
@param {string} {idColumn} - Not needed when passing children. The column name to use for RowSelectTd to pass to its selectOne function
@param {function} {rowKebabItems} - Not needed when passing children. A function that takes a single result object and returns an array of kebab items to be displayed in the last column
@param {function} {updateSearchQuery} - Pass in the updateSearchQuery function returned from useBulkSelect.
@param {function} {restrictedSearchQuery} - If included, normalize the search query to add this to all search queries to restrict search results without altering the search input value. Useful for limiting results to an initial selection. 
@param {boolean} {updateParamsByUrl} - If true, update pagination props from URL params. Default is true.
@param {string} {bookmarksPosition} - The position of the bookmarks dropdown. Default is 'left', which means the menu will take up space to its right.
*/

const TableIndexPage = ({
  apiOptions,
  apiUrl,
  beforeToolbarComponent,
  breadcrumbOptions,
  children,
  columns,
  controller,
  creatable,
  customActionButtons,
  customCreateAction,
  customExportURL,
  customHelpURL,
  customSearchProps,
  customToolbarItems,
  exportable,
  hasHelpPage,
  customHeader,
  headerText,
  header,
  isDeleteable,
  searchable,
  selectionToolbar,
  replacementResponse,
  showCheckboxes,
  rowSelectTd,
  selectOne,
  isSelected,
  idColumn,
  rowKebabItems,
  updateSearchQuery,
  restrictedSearchQuery,
  updateParamsByUrl,
  bookmarksPosition,
}) => {
  const history = useHistory();
  const { location: { search: historySearch } = {} } = history || {};
  const urlParams = new URLSearchParams(historySearch);
  const urlParamsSearch = urlParams.get('search') || '';
  const search = urlParamsSearch || getURIsearch();
  const defaultParams = { search: search || '' };
  if (updateParamsByUrl) {
    const urlPage = urlParams.get('page');
    const urlPerPage = urlParams.get('per_page');
    if (urlPage) {
      defaultParams.page = parseInt(urlPage, 10);
    }
    if (urlPerPage) {
      defaultParams.per_page = parseInt(urlPerPage, 10);
    }
  }
  const response = useTableIndexAPIResponse({
    replacementResponse,
    apiUrl,
    apiOptions,
    defaultParams,
  });

  const {
    response: {
      search: apiSearchQuery,
      can_create: canCreate,
      results,
      total,
      per_page: perPage,
      page,
      subtotal,
      message: errorMessage,
    },
    status = STATUS.PENDING,
    setAPIOptions,
  } = response;

  const memoDefaultSearchProps = useMemo(
    () => getControllerSearchProps(controller),
    [controller]
  );
  const searchProps = customSearchProps || memoDefaultSearchProps;
  searchProps.autocomplete.searchQuery = search;

  const { setParamsAndAPI, setSearch, params } = useSetParamsAndApiAndSearch({
    defaultParams,
    apiOptions,
    setAPIOptions,
    updateSearchQuery,
    pushToHistory: updateParamsByUrl,
  });

  const onPagination = newPagination => {
    setParamsAndAPI({ ...params, ...newPagination });
  };

  const onSearch = newSearch => {
    if (newSearch !== apiSearchQuery) {
      setSearch({
        search: newSearch,
        page: 1,
      });
    }
  };

  const actionButtons = [
    creatable &&
      canCreate && {
        title: __('Create new'),
        action: customCreateAction
          ? { onClick: customCreateAction() }
          : { href: createURL() },
      },
    exportable && {
      title: __('Export'),
      action: { href: customExportURL || exportURL() },
    },
    hasHelpPage && {
      title: __('Documentation'),
      icon: <QuestionCircleIcon />,
      action: { href: customHelpURL || helpURL() },
    },
    ...customActionButtons,
  ].filter(item => item);

  header = headerText || header;
  return (
    <div id="foreman-page">
      <Head>
        <title>{header}</title>
      </Head>
      {breadcrumbOptions && (
        <PageSection variant={PageSectionVariants.light} type="breadcrumb">
          <BreadcrumbBar {...breadcrumbOptions} />
        </PageSection>
      )}
      <PageSection
        variant={PageSectionVariants.light}
        className="table-title-section"
      >
        {customHeader || (
          <TextContent>
            <Text ouiaId="header-text" component="h1">
              {header}
            </Text>
          </TextContent>
        )}
      </PageSection>
      {beforeToolbarComponent}
      <PageSection
        variant={PageSectionVariants.light}
        className="table-toolbar-section"
      >
        <Toolbar ouiaId="table-toolbar" className="table-toolbar">
          <ToolbarContent>
            {searchable && (
              <ToolbarGroup
                className="toolbar-group-search"
                variant="filter-group"
              >
                {selectionToolbar}
                <ToolbarItem className="toolbar-search">
                  <SearchBar
                    data={searchProps}
                    initialQuery=""
                    restrictedSearchQuery={restrictedSearchQuery}
                    onSearch={onSearch}
                    bookmarksPosition={bookmarksPosition}
                  />
                </ToolbarItem>
                {status === STATUS.PENDING && (
                  <ToolbarItem>
                    <Spinner size="sm" />
                  </ToolbarItem>
                )}
              </ToolbarGroup>
            )}
            {(customToolbarItems || actionButtons.length > 0) && (
              <ToolbarGroup
                alignment={{ default: 'alignLeft' }}
                className="table-toolbar-actions"
                variant="button-group"
              >
                {actionButtons.length > 0 && (
                  <ToolbarItem>
                    <ActionButtons buttons={actionButtons} />
                  </ToolbarItem>
                )}
                {customToolbarItems && customToolbarItems}
              </ToolbarGroup>
            )}
            {total > 0 && (
              <Pagination
                key="table-index-page-top-pagination"
                updateParamsByUrl={updateParamsByUrl}
                variant={PaginationVariant.top}
                page={page}
                perPage={perPage}
                itemCount={subtotal}
                onChange={onPagination}
              />
            )}
          </ToolbarContent>
        </Toolbar>
      </PageSection>
      <PageSection
        variant={PageSectionVariants.light}
        className="table-section"
      >
        {children || (
          <Table
            isEmbedded={!updateParamsByUrl}
            params={{
              ...params,
              page,
              perPage,
            }}
            setParams={setParamsAndAPI}
            bottomPagination={
              <Pagination
                key="table-bottom-pagination-yes"
                page={page}
                perPage={perPage}
                itemCount={subtotal}
                onChange={onPagination}
                updateParamsByUrl={updateParamsByUrl}
              />
            }
            getActions={rowKebabItems}
            itemCount={subtotal}
            results={results}
            url={apiUrl}
            isDeleteable={isDeleteable}
            refreshData={() =>
              setAPIOptions({
                ...apiOptions,
                params: { search },
              })
            }
            columns={columns}
            errorMessage={
              status === STATUS.ERROR && errorMessage ? errorMessage : null
            }
            isPending={status === STATUS.PENDING}
            selectOne={selectOne}
            isSelected={isSelected}
            showCheckboxes={showCheckboxes}
            rowSelectTd={rowSelectTd}
            idColumn={idColumn}
          />
        )}
      </PageSection>
    </div>
  );
};

TableIndexPage.propTypes = {
  apiOptions: PropTypes.object,
  apiUrl: PropTypes.string.isRequired,
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
  beforeToolbarComponent: PropTypes.node,
  columns: PropTypes.object,
  controller: PropTypes.string,
  creatable: PropTypes.bool,
  customActionButtons: PropTypes.array,
  customCreateAction: PropTypes.func,
  customExportURL: PropTypes.string,
  customHelpURL: PropTypes.string,
  customSearchProps: PropTypes.object,
  customToolbarItems: PropTypes.node,
  replacementResponse: PropTypes.object,
  exportable: PropTypes.bool,
  hasHelpPage: PropTypes.bool,
  headerText: PropTypes.string,
  header: PropTypes.string,
  customHeader: PropTypes.node,
  isDeleteable: PropTypes.bool,
  searchable: PropTypes.bool,
  children: PropTypes.node,
  selectionToolbar: PropTypes.node,
  idColumn: PropTypes.string,
  rowSelectTd: PropTypes.func,
  selectOne: PropTypes.func,
  isSelected: PropTypes.func,
  showCheckboxes: PropTypes.bool,
  rowKebabItems: PropTypes.func,
  updateSearchQuery: PropTypes.func,
  restrictedSearchQuery: PropTypes.func,
  updateParamsByUrl: PropTypes.bool,
  bookmarksPosition: PropTypes.string,
};

TableIndexPage.defaultProps = {
  apiOptions: null,
  beforeToolbarComponent: null,
  breadcrumbOptions: null,
  columns: null,
  children: null,
  controller: '',
  creatable: true,
  customActionButtons: [],
  customCreateAction: null,
  customExportURL: '',
  customHelpURL: '',
  customSearchProps: null,
  customToolbarItems: null,
  exportable: false,
  hasHelpPage: false,
  header: '',
  headerText: '',
  customHeader: undefined,
  isDeleteable: false,
  searchable: true,
  selectionToolbar: null,
  rowSelectTd: noop,
  selectOne: noop,
  isSelected: noop,
  showCheckboxes: false,
  idColumn: 'id',
  replacementResponse: null,
  rowKebabItems: noop,
  updateSearchQuery: noop,
  restrictedSearchQuery: noop,
  updateParamsByUrl: true,
  bookmarksPosition: 'left',
};

export default TableIndexPage;
