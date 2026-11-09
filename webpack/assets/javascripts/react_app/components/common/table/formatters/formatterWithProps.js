import React from 'react';
import { Table as PfTable } from 'patternfly-react';
import { deprecate } from '../../../../common/DeprecationService';

let withPropsDeprecationLogged = false;
let withHeaderPropsDeprecationLogged = false;
let withCellPropsDeprecationLogged = false;
let headerFormatterWithPropsDeprecationLogged = false;
let cellFormatterWithPropsDeprecationLogged = false;

const logWithPropsDeprecation = () => {
  if (withPropsDeprecationLogged) {
    return;
  }

  withPropsDeprecationLogged = true;
  deprecate(
    'table/formatters/withProps',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

const logWithHeaderPropsDeprecation = () => {
  if (withHeaderPropsDeprecationLogged) {
    return;
  }

  withHeaderPropsDeprecationLogged = true;
  deprecate(
    'table/formatters/withHeaderProps',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

const logWithCellPropsDeprecation = () => {
  if (withCellPropsDeprecationLogged) {
    return;
  }

  withCellPropsDeprecationLogged = true;
  deprecate(
    'table/formatters/withCellProps',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

const logHeaderFormatterWithPropsDeprecation = () => {
  if (headerFormatterWithPropsDeprecationLogged) {
    return;
  }

  headerFormatterWithPropsDeprecationLogged = true;
  deprecate(
    'table/formatters/headerFormatterWithProps',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

const logCellFormatterWithPropsDeprecation = () => {
  if (cellFormatterWithPropsDeprecationLogged) {
    return;
  }

  cellFormatterWithPropsDeprecationLogged = true;
  deprecate(
    'table/formatters/cellFormatterWithProps',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

const createWithProps = fieldType => Component => (
  value,
  {
    column: {
      [fieldType]: { props },
    },
  }
) => <Component {...props}>{value}</Component>;

export const withProps = fieldType => {
  logWithPropsDeprecation();

  return createWithProps(fieldType);
};

export const withHeaderProps = Component => {
  logWithHeaderPropsDeprecation();

  return createWithProps('header')(Component);
};

export const withCellProps = Component => {
  logWithCellPropsDeprecation();

  return createWithProps('cell')(Component);
};

const headerFormatterWithPropsBase = withHeaderProps(PfTable.Heading);
const cellFormatterWithPropsBase = withCellProps(PfTable.Cell);

export const headerFormatterWithProps = (value, columnDefinition) => {
  logHeaderFormatterWithPropsDeprecation();

  return headerFormatterWithPropsBase(value, columnDefinition);
};

export const cellFormatterWithProps = (value, columnDefinition) => {
  logCellFormatterWithPropsDeprecation();

  return cellFormatterWithPropsBase(value, columnDefinition);
};
