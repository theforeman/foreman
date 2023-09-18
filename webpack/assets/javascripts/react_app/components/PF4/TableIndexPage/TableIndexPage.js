import React, { useState, useMemo } from 'react';
import PropTypes from 'prop-types';
import { QuestionCircleIcon } from '@patternfly/react-icons';
import { useHistory } from 'react-router-dom';
import URI from 'urijs';

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
import {
  createURL,
  exportURL,
  helpURL,
  getURIsearch,
} from '../../../common/urlHelpers';
import { translate as __ } from '../../../common/I18n';

import { useAPI } from '../../../common/hooks/API/APIHooks';
import { getControllerSearchProps, STATUS } from '../../../constants';
import BreadcrumbBar from '../../BreadcrumbBar';
import SearchBar from '../../SearchBar';
import Head from '../../Head';
import { ActionButtons } from './ActionButtons';
import './TableIndexPage.scss';
import { Table } from './Table/Table';

/**

A page component that displays a table with data fetched from an API. It provides search and filtering functionality, and the ability to create new entries and export data.
@param {Object}{apiOptions} - options object for API requests
@param {string}{apiUrl} - url for the API to make requests to
@param {React.Component} {beforeToolbarComponent} - a component to be rendered before the toolbar
@param {Object} {breadcrumbOptions} - props to send to the breadcrumb bar
@param {Object}{columns} - an object of objects representing the columns to be displayed in the table, keys should be the same as in the api response
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
@param {Array<Object>} {cutsomToolbarItems} - an array of custom toolbar items to be displayed
@param {boolean} {exportable} - whether or not to show export button
@param {boolean} {hasHelpPage} - whether or not to show documentation button
@param {string}{header} - the header text for the page
@param {boolean} {isDeleteable} - whether or not entries can be deleted
@param {boolean} {searchable} - whether or not the table can be searched
@param {React.ReactNode} {children} - optional children to be rendered inside the page instead of the table
*/

const TableIndexPage = ({
  apiOptions,
  apiUrl,
  beforeToolbarComponent,
  breadcrumbOptions,
  columns,
  controller,
  creatable,
  customActionButtons,
  customCreateAction,
  customExportURL,
  customHelpURL,
  customSearchProps,
  cutsomToolbarItems,
  exportable,
  hasHelpPage,
  header,
  isDeleteable,
  searchable,
  children,
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
  const [params, setParams] = useState(defaultParams);
  const {
    response: {
      search: apiSearchQuery,
      can_create: canCreate,
      results,
      subtotal,
      message: errorMessage,
    },
    status = STATUS.PENDING,
    setAPIOptions,
  } = useAPI(
    'get',
    apiUrl.includes('include_permissions')
      ? apiUrl
      : `${apiUrl}?include_permissions=true`,
    {
      ...apiOptions,
      params: defaultParams,
    }
  );

  const memoDefaultSearchProps = useMemo(
    () => getControllerSearchProps(controller),
    [controller]
  );
  const searchProps = customSearchProps || memoDefaultSearchProps;
  searchProps.autocomplete.searchQuery = search;
  const setParamsAndAPI = newParams => {
    // add url edit params to the new params
    const uri = new URI();
    uri.setSearch(newParams);
    history.push({ search: uri.search() });
    setParams(newParams);
    setAPIOptions({ ...apiOptions, params: newParams });
  };

  const setSearch = newSearch => {
    const uri = new URI();
    uri.setSearch(newSearch);
    history.push({ search: uri.search() });
    setParamsAndAPI({ ...params, ...newSearch });
  };

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
      <Head>
        <title>{header}</title>
      </Head>
      {breadcrumbOptions && (
        <PageSection variant={PageSectionVariants.light} type="breadcrumb">
          <BreadcrumbBar {...breadcrumbOptions} />
        </PageSection>
      )}
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text ouiaId="header-text" component="h1">
            {header}
          </Text>
        </TextContent>
      </PageSection>
      {beforeToolbarComponent}
      <PageSection variant={PageSectionVariants.light}>
        <Toolbar ouiaId="table-toolbar" className="table-toolbar">
          <ToolbarContent>
            {searchable && (
              <ToolbarGroup>
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
              <ToolbarGroup alignment={{ default: 'alignRight' }}>
                <ToolbarItem>
                  <ActionButtons buttons={actionButtons} />
                </ToolbarItem>
              </ToolbarGroup>
            )}
            {cutsomToolbarItems && (
              <ToolbarGroup>{cutsomToolbarItems}</ToolbarGroup>
            )}
          </ToolbarContent>
        </Toolbar>
      </PageSection>
      <PageSection variant={PageSectionVariants.light}>
        {children || (
          <Table
            params={params}
            setParams={setParamsAndAPI}
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
  cutsomToolbarItems: PropTypes.node,
  exportable: PropTypes.bool,
  hasHelpPage: PropTypes.bool,
  header: PropTypes.string,
  isDeleteable: PropTypes.bool,
  searchable: PropTypes.bool,
  children: PropTypes.node,
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
  cutsomToolbarItems: null,
  exportable: false,
  hasHelpPage: false,
  header: '',
  isDeleteable: false,
  searchable: true,
};

export default TableIndexPage;
