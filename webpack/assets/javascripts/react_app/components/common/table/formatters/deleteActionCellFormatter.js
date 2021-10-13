import React from 'react';
import DeleteButton from '../components/DeleteButton';

export const deleteActionCellFormatter =
  (onClick) =>
  (_, { rowData }) => {
    const { canDelete } = rowData;

    return <DeleteButton active={canDelete} onClick={() => onClick(rowData)} />;
  };
