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
@param {string}{headerText} - the header text for the page
@param {string}{header} - header node; default is <title>{headerText}</title>
@param {boolean} {isDeleteable} - whether or not entries can be deleted
@param {boolean} {searchable} - whether or not the table can be searched
@param {React.ReactNode} {selectionToolbar} - Pass in the SelectAll toolbar, if desired
@param {Object} {replacementResponse} - If included, skip the API request and use this response instead
@param {boolean} {showCheckboxes} - Not needed when passing children. Whether or not to show selection checkboxes in the first column.
@param {function} {rowSelectTd} - Not needed when passing children. A function that takes a single result object and returns a React component to be rendered in the first column.
@param {function} {rowKebabItems} - Not needed when passing children. A function that takes a single result object and returns an array of kebab items to be displayed in the last column
@param {function} {updateSearchQuery} - Pass in the updateSearchQuery function returned from useBulkSelect.
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
  headerText,
  header,
  isDeleteable,
  searchable,
  selectionToolbar,
  replacementResponse,
  showCheckboxes,
  rowSelectTd,
  rowKebabItems,
  updateSearchQuery,
}) => {
  const history = useHistory();
  const { location: { search: historySearch } = {} } = history || {};
  const urlParams = new URLSearchParams(historySearch);
  const urlParamsSearch = urlParams.get('search') || '';
  const search = urlParamsSearch || getURIsearch();
  const defaultParams = { search: search || '' };
  const urlPage = urlParams.get('page');
  const urlPerPage = urlParams.get('per_page');
  if (urlPage) {
    defaultParams.page = parseInt(urlPage, 10);
  }
  if (urlPerPage) {
    defaultParams.per_page = parseInt(urlPerPage, 10);
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

  const onPagination = newPagination => {
    setParamsAndAPI({ ...params, ...newPagination });
  };

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
  });

  const onSearch = newSearch => {
    if (newSearch !== apiSearchQuery) {
      setSearch({ search: newSearch, page: 1 });
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

  return (
    <div id="foreman-page">
      <Head>{headerText}</Head>
      {breadcrumbOptions && (
        <PageSection variant={PageSectionVariants.light} type="breadcrumb">
          <BreadcrumbBar {...breadcrumbOptions} />
        </PageSection>
      )}
      <PageSection
        variant={PageSectionVariants.light}
        className="table-title-section"
      >
        <TextContent>
          <Text ouiaId="header-text" component="h1">
            {header ?? <title>{headerText}</title>}
          </Text>
        </TextContent>
      </PageSection>
      {beforeToolbarComponent}
      <PageSection
        variant={PageSectionVariants.light}
        className="table-toolbar-section"
      >
        <Toolbar ouiaId="table-toolbar" className="table-toolbar">
          <ToolbarContent>
            {searchable && (
              <ToolbarGroup>
                {selectionToolbar}
                <ToolbarItem className="toolbar-search">
                  <SearchBar
                    data={searchProps}
                    initialQuery={apiSearchQuery}
                    onSearch={onSearch}
                  />
                </ToolbarItem>
                {status === STATUS.PENDING && (
                  <ToolbarItem>
                    <Spinner size="sm" />
                  </ToolbarItem>
                )}
              </ToolbarGroup>
            )}
            {actionButtons.length > 0 && (
              <ToolbarGroup
                alignment={{ default: 'alignLeft' }}
                className="table-toolbar-actions"
              >
                <ToolbarItem>
                  <ActionButtons buttons={actionButtons} />
                </ToolbarItem>
              </ToolbarGroup>
            )}

            {customToolbarItems && (
              <ToolbarGroup>{customToolbarItems}</ToolbarGroup>
            )}

            {total > 0 && (
              <Pagination
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
            params={params}
            setParams={setParamsAndAPI}
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
            showCheckboxes={showCheckboxes}
            rowSelectTd={rowSelectTd}
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
  header: PropTypes.node,
  isDeleteable: PropTypes.bool,
  searchable: PropTypes.bool,
  children: PropTypes.node,
  selectionToolbar: PropTypes.node,
  rowSelectTd: PropTypes.func,
  showCheckboxes: PropTypes.bool,
  rowKebabItems: PropTypes.func,
  updateSearchQuery: PropTypes.func,
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
  headerText: '',
  header: undefined,
  isDeleteable: false,
  searchable: true,
  selectionToolbar: null,
  rowSelectTd: noop,
  showCheckboxes: false,
  replacementResponse: null,
  rowKebabItems: noop,
  updateSearchQuery: noop,
};

export default TableIndexPage;
