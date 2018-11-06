import React from 'react';
import Proptypes from 'prop-types';
import { isEmpty } from 'lodash';
import { Paginator } from 'patternfly-react';
import {
  getURI,
  getURIpage,
  getURIperPage,
  changeQuery,
  translatePagination,
} from './PaginationHelper';
import './pagination.scss';

const Pagination = (props) => {
  const {
    data,
    pagination,
    onPageSet,
    onPerPageSelect,
    dropdownButtonId,
    ...otherProps
  } = props;

  const urlPage = getURIpage();
  const urlPerPage = getURIperPage();
  const className = isEmpty(data.classNames)
    ? 'col-md-12'
    : `col-md-12 ${data.classNames.pagination_classes}`;

  return (
    <Paginator
      pagination={
        isEmpty(pagination)
          ? {
              page: urlPage || 1,
              perPage: urlPerPage || data.perPage,
              perPageOptions: data.perPageOptions,
            }
          : pagination
      }
      viewType={data.viewType}
      itemCount={data.itemCount}
      onPageSet={onPageSet}
      onPerPageSelect={onPerPageSelect}
      messages={translatePagination(Paginator.defaultProps.messages)}
      className={className}
      dropdownButtonId={dropdownButtonId}
      { ...otherProps }
    />
  );
};

Pagination.propTypes = {
  data: Proptypes.shape({
    viewType: Proptypes.string,
    perPageOptions: Proptypes.arrayOf(Proptypes.number),
    itemCount: Proptypes.number,
    perPage: Proptypes.number,
  }).isRequired,
  onPageSet: Proptypes.func,
  onPerPageSelect: Proptypes.func,
  dropdownButtonId: Proptypes.string,
  pagination: Proptypes.shape({
    page: Proptypes.number,
    perPage: Proptypes.number,
    perPageOptions: Proptypes.arrayOf(Proptypes.number),
  }),
};

Pagination.defaultProps = {
  onPageSet: page => changeQuery(getURI(), { page }),
  onPerPageSelect: perPage => changeQuery(getURI(), { per_page: perPage }),
  dropdownButtonId: 'pagination-row-dropdown',
  pagination: null,
};

export default Pagination;
