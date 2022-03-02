import React from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../common/helpers';
import Breadcrumb from './components/Breadcrumb';
import PF4BreadcrumbSwitcher from '../PF4/BreadcrumbSwitcher';
import { BREADCRUMB_SWITCHER_PER_PAGE } from './BreadcrumbBarConstants';
import './BreadcrumbBar.scss';

class BreadcrumbBar extends React.Component {
  handleOpen() {
    const {
      resource,
      loadSwitcherResourcesByResource,
      currentPage,
      resourceUrl,
      resourceSwitcherItems,
    } = this.props;
    const isUrlFormatValid = resourceSwitcherItems.length
      ? resourceSwitcherItems[0].href ===
        resource.switcherItemUrl?.replace(':id', resourceSwitcherItems[0].id)
      : true;
    if (
      !currentPage ||
      resourceUrl !== resource.resourceUrl ||
      !isUrlFormatValid
    ) {
      loadSwitcherResourcesByResource(resource);
    }
  }

  render() {
    const {
      breadcrumbItems,
      isSwitchable,
      resource,
      currentPage,
      total,
      resourceSwitcherItems,
      isLoadingResources,
      hasError,
      isSwitcherOpen,
      openSwitcher,
      closeSwitcher,
      loadSwitcherResourcesByResource,
      searchQuery,
      removeSearchQuery,
      searchDebounceTimeout,
      onSwitcherItemClick,
      titleReplacement,
      perPage,
      isPf4,
    } = this.props;
    const isTitle = breadcrumbItems.length === 1;
    const handleSwitcherItemClick = (e, href) => {
      closeSwitcher();
      if (onSwitcherItemClick) {
        onSwitcherItemClick(e, href);
      } else {
        window.location.href = href;
      }
    };

    return (
      <div className={isPf4 ? 'breadcrumb-bar-pf4' : 'breadcrumb-bar'}>
        <Breadcrumb
          items={breadcrumbItems}
          isTitle={isTitle}
          titleReplacement={titleReplacement}
          className="breadcrumbs-list"
        >
          {isSwitchable && (
            <PF4BreadcrumbSwitcher
              isOpen={isSwitcherOpen}
              isLoading={isLoadingResources}
              hasError={hasError}
              items={resourceSwitcherItems}
              currentPage={currentPage}
              total={total}
              openSwitcher={openSwitcher}
              onHide={() => closeSwitcher()}
              onOpen={() => this.handleOpen()}
              onSetPage={pageNumber => {
                loadSwitcherResourcesByResource(resource, {
                  page: pageNumber,
                  searchQuery,
                  perPage,
                });
              }}
              onSearchChange={searchTerm =>
                loadSwitcherResourcesByResource(resource, {
                  searchQuery: searchTerm,
                  perPage,
                })
              }
              onPerPageSelect={newPerPage => {
                loadSwitcherResourcesByResource(resource, {
                  perPage: newPerPage,
                });
              }}
              perPage={perPage}
              searchValue={searchQuery}
              onSearchClear={() => removeSearchQuery(resource)}
              searchDebounceTimeout={searchDebounceTimeout}
              onResourceClick={handleSwitcherItemClick}
            />
          )}
        </Breadcrumb>
        {!isTitle && !isPf4 && <hr className="breadcrumb-line" />}
      </div>
    );
  }
}

BreadcrumbBar.propTypes = {
  isSwitchable: PropTypes.bool,
  resource: PropTypes.shape({
    nameField: PropTypes.string,
    resourceUrl: PropTypes.string,
    switcherItemUrl: PropTypes.string,
    resourceFilter: PropTypes.string,
  }),
  breadcrumbItems: Breadcrumb.propTypes.items,
  searchDebounceTimeout: PropTypes.number,
  searchQuery: PropTypes.string,
  currentPage: PropTypes.number,
  total: PropTypes.number,
  resourceSwitcherItems: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
      name: PropTypes.string.isRequired,
      href: PropTypes.string,
    })
  ),
  resourceUrl: PropTypes.string,
  isLoadingResources: PropTypes.bool,
  hasError: PropTypes.bool,
  isSwitcherOpen: PropTypes.bool,
  titleReplacement: PropTypes.string,
  openSwitcher: PropTypes.func,
  closeSwitcher: PropTypes.func,
  loadSwitcherResourcesByResource: PropTypes.func,
  onSwitcherItemClick: PropTypes.func,
  removeSearchQuery: PropTypes.func,
  perPage: PropTypes.number,
  isPf4: PropTypes.bool,
};

BreadcrumbBar.defaultProps = {
  isSwitchable: false,
  resource: {},
  breadcrumbItems: [],
  searchQuery: '',
  currentPage: null,
  total: 1,
  resourceSwitcherItems: [],
  resourceUrl: null,
  isLoadingResources: false,
  hasError: false,
  isSwitcherOpen: false,
  searchDebounceTimeout: 300,
  titleReplacement: null,
  openSwitcher: noop,
  closeSwitcher: noop,
  loadSwitcherResourcesByResource: noop,
  onSwitcherItemClick: null,
  removeSearchQuery: noop,
  perPage: BREADCRUMB_SWITCHER_PER_PAGE,
  isPf4: false,
};

export default BreadcrumbBar;
