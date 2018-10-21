import React from 'react';
import PropTypes from 'prop-types';
import { Popover, ListGroup, ListGroupItem, Pager, Icon } from 'patternfly-react';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import SearchInput from '../../common/SearchInput';
import SubstringWrapper from '../../common/SubstringWrapper';
import { noop } from '../../../common/helpers';
import { translate as __ } from '../../../../react_app/common/I18n';
import './BreadcrumbSwitcherPopover.scss';

const BreadcrumbSwitcherPopover = ({
  resources,
  onNextPageClick,
  onPrevPageClick,
  loading,
  hasError,
  currentPage,
  totalPages,
  onSearchChange,
  onSearchClear,
  searchValue,
  searchDebounceTimeout,
  onResourceClick,
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

      return { ...itemProps, onClick: e => onResourceClick(e, url), href: url };
    };

    popoverBody = (
      <React.Fragment>
        <ListGroup className="scrollable-list">
          {resources.map(resource => (
            <ListGroupItem {...createItemProps(resource)}>
              <EllipsisWithTooltip>
                <SubstringWrapper substring={searchValue}>
                  {resource.name}
                </SubstringWrapper>
              </EllipsisWithTooltip>
            </ListGroupItem>
          ))}
        </ListGroup>
        <Pager
          className="pager-sm"
          messages={{ nextPage: '', previousPage: '' }}
          onNextPage={onNextPageClick}
          onPreviousPage={onPrevPageClick}
          disablePrevious={currentPage === 1}
          disableNext={totalPages === 0 || currentPage === Math.ceil(totalPages)}
        />
      </React.Fragment>
    );
  }

  return (
    <Popover className="breadcrumb-switcher-popover" {...props}>
      <SearchInput
        onClear={onSearchClear}
        timeout={searchDebounceTimeout}
        focus
        onSearchChange={onSearchChange}
        searchValue={searchValue} />
      {popoverBody}
    </Popover>
  );
};

BreadcrumbSwitcherPopover.propTypes = {
  ...Popover.propTypes,
  searchValue: PropTypes.string,
  loading: PropTypes.bool,
  hasError: PropTypes.bool,
  currentPage: PropTypes.number,
  totalPages: PropTypes.number,
  resources: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    name: PropTypes.string.isRequired,
    href: PropTypes.string,
    onClick: PropTypes.func,
  })),
  onSearchChange: PropTypes.func,
  onResourceClick: PropTypes.func,
};

BreadcrumbSwitcherPopover.defaultProps = {
  searchValue: '',
  loading: false,
  hasError: false,
  currentPage: 1,
  totalPages: 1,
  resources: [],
  onResourceClick: noop,
};

export default BreadcrumbSwitcherPopover;
