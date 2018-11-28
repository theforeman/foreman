import React from 'react';
import PropTypes from 'prop-types';
import { Paginator } from 'patternfly-react';
import Pagination from './Pagination';

const PaginationWrapper = props => {
  const {
    onPageSet,
    onPerPageSelect,
    onChange,
    pagination,
    dropdownButtonId,
    itemCount,
    viewType,
    ...otherProps
  } = props;

  const onPageSetUpdate = page => {
    update({ page });
    onPageSet(page);
  };

  const onPerPageSelectUpdate = perPage => {
    update({ perPage, page: 1 });
    onPerPageSelect(perPage);
  };

  const update = changes => {
    const newPagination = { ...pagination, ...changes };

    onChange({
      page: newPagination.page,
      perPage: newPagination.perPage,
    });
  };

  const initPagination = paginationFromProps => {
    const defaultPagination = {
      page: 1,
      perPage: 20,
      perPageOptions: [5, 10, 15, 20, 25, 50],
    };
    return { ...defaultPagination, ...(paginationFromProps || {}) };
  };

  return (
    <Pagination
      data={{ itemCount, viewType }}
      onPageSet={onPageSetUpdate}
      onPerPageSelect={onPerPageSelectUpdate}
      dropdownButtonId={dropdownButtonId}
      pagination={initPagination(pagination)}
      {...otherProps}
    />
  );
};

PaginationWrapper.defaultProps = {
  onChange: () => {},
  viewType: 'list',
  ...Paginator.defaultProps,
};

PaginationWrapper.propTypes = {
  ...Paginator.propTypes,
  /** page and per-page selection callback */
  onChange: PropTypes.func,
  /** view type */
  viewType: PropTypes.string,
  /** pagination */
  pagination: PropTypes.shape({
    /** the current page */
    page: PropTypes.number,
    /** the current per page setting */
    perPage: PropTypes.number,
    /** per page options */
    perPageOptions: PropTypes.arrayOf(PropTypes.number),
  }),
};

export default PaginationWrapper;
