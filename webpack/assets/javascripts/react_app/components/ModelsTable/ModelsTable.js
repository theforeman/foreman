import React, { useEffect } from 'react';
import { Spinner } from 'patternfly-react';
import PropTypes from 'prop-types';
import { Table } from '../common/table';
import { STATUS } from '../../constants';
import MessageBox from '../common/MessageBox';
import { translate as __ } from '../../common/I18n';
import createModelsTableSchema from './ModelsTableSchema';
import { getURIQuery } from '../../common/helpers';

const ModelsTable = ({
  getTableItems,
  sortBy,
  sortOrder,
  error,
  status,
  results,
  itemCount,
  pagination,
  onPaginationChange,
}) => {
  useEffect(() => {
    getTableItems(getURIQuery(window.location.href));
  }, [pagination.page, pagination.perPage]);

  if (results.length === 0) {
    return <Spinner size="lg" loading />;
  }

  if (status === STATUS.ERROR) {
    return (
      <MessageBox
        key="models-table-error"
        icontype="error-circle-o"
        msg={__(`Could not receive data: ${error && error.message}`)}
      />
    );
  }

  return (
    <Table
      key="models-table"
      columns={createModelsTableSchema(getTableItems, sortBy, sortOrder)}
      rows={results}
      isPaginated
      itemCount={itemCount}
      pagination={pagination}
      onPaginationChange={onPaginationChange}
    />
  );
};

ModelsTable.propTypes = {
  results: PropTypes.array.isRequired,
  getTableItems: PropTypes.func.isRequired,
  status: PropTypes.oneOf(Object.keys(STATUS)),
  sortBy: PropTypes.string,
  sortOrder: PropTypes.string,
  error: PropTypes.object,
  itemCount: PropTypes.number,
  pagination: PropTypes.shape({
    page: PropTypes.number,
    perPage: PropTypes.number,
  }),
  onPaginationChange: PropTypes.func.isRequired,
};

ModelsTable.defaultProps = {
  status: STATUS.PENDING,
  sortBy: '',
  sortOrder: '',
  error: null,
  itemCount: 0,
  pagination: {},
};

export default ModelsTable;
