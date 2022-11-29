import { useState } from 'react';
import { translate as __ } from '../../../common/I18n';

export const useTableSort = ({
  allColumns,
  columnsToSortParams,
  initialSortColumnName,
  onSort: _onSort,
}) => {
  const translatedInitialSortColumnName = initialSortColumnName
    ? __(initialSortColumnName)
    : allColumns[0];
  if (
    !Object.keys(columnsToSortParams).includes(translatedInitialSortColumnName)
  ) {
    throw new Error(
      `translatedInitialSortColumnName '${translatedInitialSortColumnName}' must also be defined in columnsToSortParams`
    );
  }
  const [activeSortColumn, setActiveSortColumn] = useState(
    translatedInitialSortColumnName
  );
  const [activeSortDirection, setActiveSortDirection] = useState('asc');

  if (!allColumns.includes(activeSortColumn)) {
    setActiveSortColumn(translatedInitialSortColumnName);
  }

  // Patternfly sort function
  const onSort = (_event, index, direction) => {
    setActiveSortColumn(allColumns?.[index]);
    setActiveSortDirection(direction);
    _onSort(_event, index, direction);
  };

  // Patternfly sort params to pass to the <Th> component.
  // (but you should probably just use <SortableColumnHeaders> instead)
  const pfSortParams = (columnName, newSortColIndex) => ({
    columnIndex: newSortColIndex ?? allColumns?.indexOf(columnName),
    sortBy: {
      defaultDirection: 'asc',
      direction: activeSortDirection,
      index: allColumns?.indexOf(activeSortColumn),
    },
    onSort,
  });

  return {
    pfSortParams,
    apiSortParams: {
      // scoped_search params to pass to the Katello API
      sort_by: columnsToSortParams[activeSortColumn],
      sort_order: activeSortDirection,
    },
    activeSortColumn, // state values to pass as additionalListeners
    activeSortDirection,
  };
};
