import React from 'react';
import SortableHeader from '../components/SortableHeader';

const sortableHeaderFormatter = sortController => (label, { property }) => {
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

export default sortableHeaderFormatter;
