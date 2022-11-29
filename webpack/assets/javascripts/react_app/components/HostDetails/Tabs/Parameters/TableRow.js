import React from 'react';
import PropTypes from 'prop-types';
import { EditParametersTableRow } from './EditTableRow';
import { ViewParametersTableRow } from './ViewTableRow';

export const ParametersTableRow = ({
  rowIndex,
  editingRow,
  isNew,
  ...props
}) => {
  if (isNew || editingRow === rowIndex) {
    return (
      <EditParametersTableRow isNew={isNew} rowIndex={rowIndex} {...props} />
    );
  }
  return <ViewParametersTableRow rowIndex={rowIndex} {...props} />;
};

ParametersTableRow.propTypes = {
  rowIndex: PropTypes.number.isRequired,
  editingRow: PropTypes.number.isRequired,
  isNew: PropTypes.bool,
};

ParametersTableRow.defaultProps = { isNew: false };
