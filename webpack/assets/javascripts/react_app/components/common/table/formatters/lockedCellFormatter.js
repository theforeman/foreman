import React from 'react';
import LockedCell from '../components/LockedCell';

const lockedCellFormatter = () => (
  value
) => (
  <LockedCell
    condition={value}
  />
);

export default lockedCellFormatter;
