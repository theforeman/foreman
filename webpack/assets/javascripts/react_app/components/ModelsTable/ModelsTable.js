import React from 'react';
import PropTypes from 'prop-types';
import { Table } from '../common/table';
import createModelsTableSchema from './ModelsTableSchema';

const ModelsTable = ({
  getTableItems,
  sortBy,
  sortOrder,
  results,
  onDeleteClick,
  id,
}) => (
  <Table
    key="models-table"
    columns={createModelsTableSchema(
      getTableItems,
      sortBy,
      sortOrder,
      onDeleteClick
    )}
    rows={results}
    id={id}
  />
);

ModelsTable.propTypes = {
  results: PropTypes.array.isRequired,
  getTableItems: PropTypes.func.isRequired,
  onDeleteClick: PropTypes.func.isRequired,
  sortBy: PropTypes.string,
  sortOrder: PropTypes.string,
  id: PropTypes.string,
};

ModelsTable.defaultProps = {
  sortBy: '',
  sortOrder: '',
  id: undefined,
};

export default ModelsTable;
