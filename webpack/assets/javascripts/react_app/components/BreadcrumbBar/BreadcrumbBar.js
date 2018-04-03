import React from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../common/helpers';
import Breadcrumb from './components/Breadcrumb';
import BreadcrumbSwitcher from './components/BreadcrumbSwitcher';

class BreadcrumbBar extends React.Component {
  handleOpen() {
    const {
      data: { resource },
      loadSwitcherResourcesByResource,
      currentPage,
      resourceUrl,
    } = this.props;

    if (!currentPage || resourceUrl !== resource.resourceUrl) {
      loadSwitcherResourcesByResource(resource);
    }
  }

  render() {
    const {
      data: { breadcrumbItems, isSwitchable, resource },
      currentPage,
      totalPages,
      resourceSwitcherItems,
      isLoadingResources,
      hasError,
      isSwitcherOpen,
      toggleSwitcher,
      closeSwitcher,
      loadSwitcherResourcesByResource,
    } = this.props;

    const isTitle = breadcrumbItems.length === 1;
    return (
      <div className="breadcrumb-bar">
        <Breadcrumb title items={breadcrumbItems} isTitle={isTitle}>
          {isSwitchable && (
            <BreadcrumbSwitcher
              open={isSwitcherOpen}
              isLoadingResources={isLoadingResources}
              hasError={hasError}
              resources={resourceSwitcherItems}
              currentPage={currentPage}
              totalPages={totalPages}
              onTogglerClick={() => toggleSwitcher()}
              onHide={() => closeSwitcher()}
              onOpen={() => this.handleOpen()}
              onResourceClick={() => closeSwitcher()}
              onNextPageClick={() =>
                loadSwitcherResourcesByResource(resource, { page: Number(currentPage) + 1 })
              }
              onPrevPageClick={() =>
                loadSwitcherResourcesByResource(resource, { page: Number(currentPage) - 1 })
              }
            />
          )}
        </Breadcrumb>
        {!isTitle && <hr className="breadcrumb-line" />}
      </div>
    );
  }
}

BreadcrumbBar.propTypes = {
  data: PropTypes.shape({
    isSwitchable: PropTypes.bool,
    resource: PropTypes.shape({
      nameField: PropTypes.string,
      resourceUrl: PropTypes.string,
      switcherItemUrl: PropTypes.string,
    }),
    breadcrumbItems: Breadcrumb.propTypes.items,
  }),
  currentPage: PropTypes.number,
  totalPages: PropTypes.number,
  resourceSwitcherItems: BreadcrumbSwitcher.propTypes.resources,
  resourceUrl: PropTypes.string,
  isLoadingResources: PropTypes.bool,
  hasError: PropTypes.bool,
  isSwitcherOpen: PropTypes.bool,
  toggleSwitcher: PropTypes.func,
  closeSwitcher: PropTypes.func,
  loadSwitcherResourcesByResource: PropTypes.func,
};

BreadcrumbBar.defaultProps = {
  data: {
    breadcrumbItems: [],
    isSwitchable: false,
  },
  currentPage: null,
  totalPages: 1,
  resourceSwitcherItems: [],
  resourceUrl: null,
  isLoadingResources: false,
  hasError: false,
  isSwitcherOpen: false,
  toggleSwitcher: noop,
  closeSwitcher: noop,
  loadSwitcherResourcesByResource: noop,
};

export default BreadcrumbBar;
