import React from '@theforeman/vendor/react';
import { Table as PfTable } from '@theforeman/vendor/patternfly-react';

export const withProps = Component => (
  value,
  {
    column: {
      header: { props },
    },
  }
) => <Component {...props}>{value}</Component>;

export const headerFormatterWithProps = withProps(PfTable.Heading);
export const cellFormatterWithProps = withProps(PfTable.Cell);
