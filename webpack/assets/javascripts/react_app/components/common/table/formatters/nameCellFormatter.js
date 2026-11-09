import React from 'react';
import NameCell from '../components/NameCell';
import { deprecate } from '../../../../common/DeprecationService';

let nameCellFormatterDeprecationLogged = false;

const logNameCellFormatterDeprecation = () => {
  if (nameCellFormatterDeprecationLogged) {
    return;
  }

  nameCellFormatterDeprecationLogged = true;
  deprecate(
    'table/formatters/nameCellFormatter',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

const nameCellFormatter = controllerPluralize => {
  logNameCellFormatterDeprecation();

  return (value, { rowData: { canEdit, id, name } }) => (
    <NameCell
      active={canEdit}
      id={id}
      name={encodeURI(name)}
      controller={controllerPluralize}
    >
      {value}
    </NameCell>
  );
};

export default nameCellFormatter;
