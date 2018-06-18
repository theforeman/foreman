import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { Overlay } from 'react-bootstrap';

import { noop } from '../../../common/helpers';

import BreadcrumbSwitcherPopover from './BreadcrumbSwitcherPopover';
import BreadcrumbSwitcherToggler from './BreadcrumbSwitcherToggler';

class BreadcrumbSwitcher extends React.Component {
  componentDidUpdate(prevProps) {
    const { open, onOpen } = this.props;

    if (open === true && prevProps.open === false) {
      onOpen();
    }
  }

  render() {
    const {
      open,
      currentPage,
      totalPages,
      isLoadingResources,
      hasError,
      resources,
      onTogglerClick,
      onHide,
      onNextPageClick,
      onPrevPageClick,
      onSearchChange,
      searchValue,
      onSearchClear,
      searchDebounceTimeout,
      onResourceClick,
    } = this.props;

    return (
      <div className="breadcrumb-switcher" style={{ position: 'relative' }}>
        <BreadcrumbSwitcherToggler
          id='switcher'
          onClick={() => onTogglerClick()}
          ref={(ref) => {
            this.togglerRef = ref;
          }}
        />

        <Overlay
          rootClose
          show={open}
          container={this}
          placement="bottom"
          onHide={onHide}
          target={() => ReactDOM.findDOMNode(this.togglerRef)}
        >
          <BreadcrumbSwitcherPopover
            id="breadcrumb-switcher-popover"
            loading={isLoadingResources}
            hasError={hasError}
            onSearchChange={onSearchChange}
            resources={resources}
            onNextPageClick={onNextPageClick}
            onPrevPageClick={onPrevPageClick}
            currentPage={currentPage}
            totalPages={totalPages}
            searchValue={searchValue}
            onSearchClear={onSearchClear}
            searchDebounceTimeout={searchDebounceTimeout}
            onResourceClick={onResourceClick}
          />
        </Overlay>
      </div>
    );
  }
}

BreadcrumbSwitcher.propTypes = {
  open: PropTypes.bool,
  currentPage: PropTypes.number,
  totalPages: PropTypes.number,
  isLoadingResources: PropTypes.bool,
  hasError: PropTypes.bool,
  resources: BreadcrumbSwitcherPopover.propTypes.resources,
  onTogglerClick: PropTypes.func,
  onHide: PropTypes.func,
  onOpen: PropTypes.func,
  onPrevPageClick: PropTypes.func,
  onNextPageClick: PropTypes.func,
  onResourceClick: PropTypes.func,
};

BreadcrumbSwitcher.defaultProps = {
  open: false,
  currentPage: 1,
  totalPages: 1,
  isLoadingResources: false,
  hasError: false,
  resources: [],
  onTogglerClick: noop,
  onHide: noop,
  onOpen: noop,
  onResourceClick: noop,
  onPrevPageClick: noop,
  onNextPageClick: noop,
};

export default BreadcrumbSwitcher;
