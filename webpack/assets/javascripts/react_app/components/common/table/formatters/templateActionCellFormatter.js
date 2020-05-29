import React from 'react';
import { cellFormatter } from '../../table';
import { TemplateActionButton } from '../components/TemplateActionButton';

const templateActionCellFormatter = templateActions => (
  value,
  { rowData: { id, name, vendor, can_delete: canDelete } }
) => {
  const permissions = { canDelete: canDelete };
  return cellFormatter(
    <TemplateActionButton
    id={id}
    name={name}
    vendor={vendor}
    templateActions={templateActions}
    availableActions={value}
    permissions={permissions}
    />
  );
};

export default templateActionCellFormatter;
