import React from 'react';
import { Table as PfTable } from 'patternfly-react';

export const withProps =
  (fieldType) =>
  (Component) =>
  (
    value,
    {
      column: {
        [fieldType]: { props },
      },
    }
  ) =>
    <Component {...props}>{value}</Component>;

export const withHeaderProps = withProps('header');
export const withCellProps = withProps('cell');

export const headerFormatterWithProps = withHeaderProps(PfTable.Heading);
export const cellFormatterWithProps = withCellProps(PfTable.Cell);
