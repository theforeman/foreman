import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { QuestionCircleIcon } from '@patternfly/react-icons';
import { useHistory } from 'react-router-dom';
import { isEqual } from 'lodash';
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
  changeQuery,
  getURIsearch,
  getURI,
} from '../../../common/urlHelpers';
import { translate as __ } from '../../../common/I18n';

import { useAPI } from '../../../common/hooks/API/APIHooks';
import { getControllerSearchProps, STATUS } from '../../../constants';
import BreadcrumbBar from '../../BreadcrumbBar';
import SearchBar from '../../SearchBar';
import Head from '../../Head';
import { ActionButtons } from './ActionButtons';
import './TableIndexPage.scss';

const TableIndexPage = ({
  apiUrl,
  apiOptions,
  header,
  breadcrumbOptions,
  beforeToolbarComponent,
  controller,
  searchable,
  exportable,
  creatable,
  hasHelpPage,
  customSearchProps,
  customExportURL,
  customCreateAction,
  customHelpURL,
  customActionButtons,
  cutsomToolbarItems,
  children,
}) => {
  const history = useHistory();
  const { location: { search: historySearch } = {} } = history || {};
  const urlParams = new URLSearchParams(historySearch);
  const urlParamsSearch = urlParams.get('search') || '';
  const search = urlParamsSearch || getURIsearch();
  const {
    response: { search: apiSearchQuery, can_create: canCreate },
    status = STATUS.PENDING,
    setAPIOptions,
  } = useAPI('get', apiUrl, { ...apiOptions, params: { search } });

  const memoDefaultSearchProps = useMemo(
    () => getControllerSearchProps(controller),
    [controller]
  );
  const searchProps = customSearchProps || memoDefaultSearchProps;
  searchProps.autocomplete.searchQuery = search;
  const onSearch = newSearch => {
    const params = { search: newSearch, page: 1 };
    if (history) {
      const uri = new URI();
      uri.removeSearch('search');
      uri.addSearch(params);
      history.push({ search: uri.search() });
    } else {
      const uri = new URI(getURI());
      uri.removeSearch('search');
      uri.addSearch(params);
      changeQuery(uri.search());
    }
    if (!isEqual(newSearch, search)) setAPIOptions({ params });
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
    <div className="foreman-page">
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
                <ToolbarItem>
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
              <ToolbarGroup>
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
      <PageSection variant={PageSectionVariants.light}>{children}</PageSection>
    </div>
  );
};

TableIndexPage.propTypes = {
  apiUrl: PropTypes.string.isRequired,
  header: PropTypes.string,
  apiOptions: PropTypes.object,
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
  controller: PropTypes.string,
  searchable: PropTypes.bool,
  exportable: PropTypes.bool,
  creatable: PropTypes.bool,
  hasHelpPage: PropTypes.bool,
  customSearchProps: PropTypes.object,
  customExportURL: PropTypes.string,
  customCreateAction: PropTypes.func,
  customHelpURL: PropTypes.string,
  customActionButtons: PropTypes.array,
  children: PropTypes.node.isRequired,
  cutsomToolbarItems: PropTypes.node,
};

TableIndexPage.defaultProps = {
  header: '',
  apiOptions: null,
  breadcrumbOptions: null,
  beforeToolbarComponent: null,
  controller: '',
  searchable: true,
  exportable: false,
  creatable: true,
  hasHelpPage: false,
  customSearchProps: null,
  customExportURL: '',
  customCreateAction: null,
  customHelpURL: '',
  customActionButtons: [],
  cutsomToolbarItems: null,
};

export default TableIndexPage;
