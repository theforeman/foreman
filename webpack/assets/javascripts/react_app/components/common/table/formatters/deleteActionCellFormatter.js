import React, { useEffect } from 'react';
import DeleteButton from '../components/DeleteButton';
import { deprecate } from '../../../../common/DeprecationService';

export const deleteActionCellFormatter = onClick => (_, { rowData }) => {
  const { canDelete } = rowData;

  useEffect(() => {
    deprecate(
      'table/formatters/deleteActionCellFormatter',
      'Table Actions from @patternfly/react-core',
      '3.21'
    );
  }, []);

  return <DeleteButton active={canDelete} onClick={() => onClick(rowData)} />;
};
