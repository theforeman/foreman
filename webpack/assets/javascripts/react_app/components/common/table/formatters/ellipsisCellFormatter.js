import React from 'react';
import { Truncate } from '@patternfly/react-core';
import cellFormatter from './cellFormatter';
import { deprecate } from '../../../../common/DeprecationService';

let ellipsisCellFormatterDeprecationLogged = false;

const logEllipsisCellFormatterDeprecation = () => {
  if (ellipsisCellFormatterDeprecationLogged) {
    return;
  }

  ellipsisCellFormatterDeprecationLogged = true;
  deprecate(
    'table/formatters/ellipsisCellFormatter',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

export default value => {
  logEllipsisCellFormatterDeprecation();

  return cellFormatter(<Truncate content={value || ''} />);
};
