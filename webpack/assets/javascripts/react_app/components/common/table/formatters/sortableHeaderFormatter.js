import React from 'react';
import SortableHeader from '../components/SortableHeader';
import { deprecate } from '../../../../common/DeprecationService';

let sortableHeaderFormatterDeprecationLogged = false;

const logSortableHeaderFormatterDeprecation = () => {
  if (sortableHeaderFormatterDeprecationLogged) {
    return;
  }

  sortableHeaderFormatterDeprecationLogged = true;
  deprecate(
    'table/formatters/sortableHeaderFormatter',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

const sortableHeaderFormatter = sortController => {
  logSortableHeaderFormatterDeprecation();

  return (label, { property }) => {
    const isSorter = property === sortController.property;
    const currentOrder = isSorter ? sortController.order : '';
    const nextOrder = currentOrder === 'ASC' ? 'DESC' : 'ASC';

    return (
      <SortableHeader
        onClick={() => {
          sortController.apply(property, nextOrder);
        }}
        sortOrder={isSorter ? sortController.order.toLowerCase() : null}
      >{` ${label}`}</SortableHeader>
    );
  };
};

export default sortableHeaderFormatter;
