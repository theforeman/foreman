import React from 'react';
import PropTypes from 'prop-types';
import { Popover, ListGroup, ListGroupItem, Pager, Icon } from 'patternfly-react';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';

import { noop } from '../../../common/helpers';
import './BreadcrumbSwitcherPopover.scss';

const BreadcrumbSwitcherPopover = ({
  resources,
  onResourceClick,
  onNextPageClick,
  onPrevPageClick,
  loading,
  hasError,
  currentPage,
  totalPages,
  appear, // remove the appear from the ...props
  ...props
}) => {
  let popoverBody;

  if (loading) {
    popoverBody = (
      <div className="breadcrumb-switcher-popover-loading text-center">
        <Icon name="spinner" spin size="lg" />
      </div>
    );
  } else if (hasError) {
    popoverBody = (
      <div className="breadcrumb-switcher-popover-error">
        {__('Error: Unable to load resources.')}
      </div>
    );
  } else {
    const handleItemClick = (item) => {
      onResourceClick(item);
      if (item.onClick) item.onClick();
    };

    const createItemProps = (item) => {
      const { id, url, name } = item;
      const key = `${id}-${name}`;

      const itemProps = {
        key,
        id: key,
        className: 'no-border',
        active: url === window.location.pathname,
      };

      if (itemProps.active) {
        return { ...itemProps, disabled: true };
      }

      return { ...itemProps, onClick: () => handleItemClick(item), href: url };
    };

    popoverBody = (
      <React.Fragment>
        <ListGroup className="scrollable-list">
          {resources.map(resource => (
              <ListGroupItem {...createItemProps(resource)}>
                <EllipsisWithTooltip>{resource.name}</EllipsisWithTooltip>
              </ListGroupItem>
            ))}
        </ListGroup>
        <Pager
          className="pager-sm"
          messages={{ nextPage: __('Next'), previousPage: __('Previous') }}
          onNextPage={onNextPageClick}
          onPreviousPage={onPrevPageClick}
          disablePrevious={currentPage === 1}
          disableNext={currentPage === Math.ceil(totalPages)}
        />
      </React.Fragment>
    );
  }

  return (
    <Popover className="breadcrumb-switcher-popover" {...props}>
      {popoverBody}
    </Popover>
  );
};

BreadcrumbSwitcherPopover.propTypes = {
  ...Popover.propTypes,
  loading: PropTypes.bool,
  hasError: PropTypes.bool,
  currentPage: PropTypes.number,
  totalPages: PropTypes.number,
  onResourceClick: PropTypes.func,
  resources: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    href: PropTypes.string,
    onClick: PropTypes.func,
  })),
};

BreadcrumbSwitcherPopover.defaultProps = {
  loading: false,
  hasError: false,
  currentPage: 1,
  totalPages: 1,
  onResourceClick: noop,
  resources: [],
};

export default BreadcrumbSwitcherPopover;
