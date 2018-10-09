import React from 'react';
import PropTypes from 'prop-types';
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

const Pagination = ({ data }) => {
  const urlPage = getURIpage();
  const urlPerPage = getURIperPage();
  const className = isEmpty(data.classNames)
    ? 'col-md-12'
    : `col-md-12 ${data.classNames.pagination_classes}`;

  return (
    <Paginator
      pagination={{
        page: urlPage || 1,
        perPage: urlPerPage || data.perPage,
        perPageOptions: data.perPageOptions,
      }}
      viewType={data.viewType}
      itemCount={data.itemCount}
      onPageSet={page => changeQuery(getURI(), { page })}
      onPerPageSelect={perPage => changeQuery(getURI(), { per_page: perPage })}
      messages={translatePagination(Paginator.defaultProps.messages)}
      className={className}
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
};

export default Pagination;
