import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { isEmpty } from 'lodash';
import { Paginator } from 'patternfly-react';
import { translateObject } from '../../common/helpers';
import {
  getURI,
  getURIpage,
  getURIperPage,
  changeQuery,
} from './PaginationHelper';
import './pagination.scss';

const Pagination = props => {
  const {
    data,
    pagination,
    onPageSet,
    onPerPageSelect,
    disableNext,
    disablePrev,
    dropdownButtonId,
    ...otherProps
  } = props;

  const urlPage = getURIpage();
  const urlPerPage = getURIperPage();
  const className = classNames(
    'col-md-12',
    data.classNames.pagination_classes,
    { disable_next: disableNext, disable_prev: disablePrev }
  );

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
      messages={translateObject(Paginator.defaultProps.messages)}
      className={className}
      dropdownButtonId={dropdownButtonId}
      {...otherProps}
    />
  );
};

Pagination.propTypes = {
  data: PropTypes.shape({
    viewType: PropTypes.string,
    perPageOptions: PropTypes.arrayOf(PropTypes.number),
    itemCount: PropTypes.number,
    perPage: PropTypes.number,
  }).isRequired,
  onPageSet: PropTypes.func,
  onPerPageSelect: PropTypes.func,
  disableNext: PropTypes.bool,
  disablePrev: PropTypes.bool,
  dropdownButtonId: PropTypes.string,
  pagination: PropTypes.shape({
    page: PropTypes.number,
    perPage: PropTypes.number,
    perPageOptions: PropTypes.arrayOf(PropTypes.number),
  }),
};

Pagination.defaultProps = {
  onPageSet: page => changeQuery(getURI(), { page }),
  onPerPageSelect: perPage =>
    changeQuery(getURI(), { page: 1, per_page: perPage }),
  dropdownButtonId: 'pagination-row-dropdown',
  pagination: null,
  disableNext: false,
  disablePrev: false,
};

export default Pagination;
