import React, { useEffect } from 'react';
import { Spinner } from 'patternfly-react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Table, getSelectionController } from '../common/table';
import { STATUS } from '../../constants';
import MessageBox from '../common/MessageBox';
import { translate as __ } from '../../common/I18n';
import createModelsTableSchema from './ModelsTableSchema';
import { getURIQuery } from '../../common/helpers';
import { SelectAllAlert } from './SelectAllAlert';
import { MODELS_TABLE_ID } from './ModelsTableConstants';

const ModelsTable = ({
  getTableItems,
  sortBy,
  sortOrder,
  error,
  status,
  results,
  total,
  pagination,
  allRowsSelected,
  selectedRows,
  showSelectAll,
  unselectAllRows,
  selectAllRows,
}) => {
  useEffect(() => {
    getTableItems(getURIQuery(window.location.href));
  }, [getTableItems]);

  const dispatch = useDispatch();

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
  const selectionController = getSelectionController({
    tableID: MODELS_TABLE_ID,
    allRowsSelected,
    rows: results,
    selectedRows,
    dispatch,
  });
  return (
    <React.Fragment>
      {showSelectAll && total >= pagination.perPage && (
        <SelectAllAlert
          itemCount={total}
          perPage={pagination.perPage}
          selectAllRows={() => selectAllRows(MODELS_TABLE_ID)}
          unselectAllRows={() => unselectAllRows(MODELS_TABLE_ID)}
          allRowsSelected={allRowsSelected}
        />
      )}
      <Table
        key="models-table"
        columns={createModelsTableSchema(
          getTableItems,
          sortBy,
          sortOrder,
          selectionController
        )}
        rows={results}
      />
    </React.Fragment>
  );
};

ModelsTable.propTypes = {
  results: PropTypes.array.isRequired,
  getTableItems: PropTypes.func.isRequired,
  status: PropTypes.oneOf(Object.keys(STATUS)),
  sortBy: PropTypes.string,
  sortOrder: PropTypes.string,
  error: PropTypes.object,
  total: PropTypes.number.isRequired,
  pagination: PropTypes.shape({
    page: PropTypes.number,
    perPage: PropTypes.number,
  }).isRequired,
  allRowsSelected: PropTypes.bool.isRequired,
  showSelectAll: PropTypes.bool.isRequired,
  selectedRows: PropTypes.array.isRequired,
  unselectAllRows: PropTypes.func.isRequired,
  selectAllRows: PropTypes.func.isRequired,
};

ModelsTable.defaultProps = {
  status: STATUS.PENDING,
  sortBy: '',
  sortOrder: '',
  error: null,
};

export default ModelsTable;
