import React from 'react';
import NameCell from '../components/NameCell';

const nameCellFormatter = controllerPluralize => (
  value,
  { rowData: { can_edit: canEdit, id, name } }
) => (
  <NameCell
    active={canEdit}
    id={id}
    name={encodeURI(name)}
    controller={controllerPluralize}
  >
    {value}
  </NameCell>
);

export default nameCellFormatter;
