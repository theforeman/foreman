import React from 'react';
import PropTypes from 'prop-types';
import { Tr, Td, TableText } from '@patternfly/react-table';
import { PencilAltIcon, FlagIcon } from '@patternfly/react-icons';
import { Button, Tooltip } from '@patternfly/react-core';
import { translate as __ } from '../../../../common/I18n';
import { HOST_PARAM, columnNames } from './ParametersConstants';
import { RowActions } from './RowActions';

const getValue = param => {
  if (param['hidden_value?']) {
    return '••••••••';
  }
  if (param.parameter_type === 'boolean') {
    return param.value.toString();
  }
  if (!param.value)
    return <span className="disabled-text">{__('No value')}</span>;
  if (['json', 'yaml', 'array', 'hash'].includes(param.parameter_type)) {
    return JSON.stringify(param.value);
  }
  return param.value;
};

export const ViewParametersTableRow = ({
  param,
  rowIndex,
  setEditingRow,
  hostId,
  editHostsPermission,
}) => (
  <Tr ouiaId={`view-parameter-row-${rowIndex}`} key={rowIndex}>
    <Td dataLabel={columnNames.name}>
      <>
        {param.override && (
          <>
            <Tooltip content={__('Overridden')}>
              <FlagIcon />{' '}
            </Tooltip>
          </>
        )}
        {param.name}
      </>
    </Td>
    <Td dataLabel={columnNames.type}>{param.parameter_type}</Td>
    <Td dataLabel={columnNames.value}>
      <TableText wrapModifier="truncate">{getValue(param)}</TableText>
    </Td>
    <Td dataLabel={columnNames.source}>{param.associated_type}</Td>
    {editHostsPermission && (
      <Td isActionCell className="parameters-row-actions">
        <Tooltip
          content={
            param.associated_type === HOST_PARAM ? __('edit') : __('override')
          }
        >
          <Button
            ouiaId={`view-parameters-table-row-edit-${rowIndex}`}
            aria-label={
              param.associated_type === HOST_PARAM
                ? `edit ${param.name}`
                : `override ${param.name}`
            }
            variant="plain"
            onClick={() => {
              setEditingRow(rowIndex);
            }}
          >
            <PencilAltIcon />
          </Button>
        </Tooltip>
      </Td>
    )}
    <RowActions
      hostId={hostId}
      param={param}
      editHostsPermission={editHostsPermission}
    />
  </Tr>
);

ViewParametersTableRow.propTypes = {
  param: PropTypes.shape({
    name: PropTypes.string,
    parameter_type: PropTypes.string,
    value: PropTypes.any,
    id: PropTypes.number,
    'hidden_value?': PropTypes.bool,
    override: PropTypes.bool,
    associated_type: PropTypes.string,
  }).isRequired,
  rowIndex: PropTypes.number.isRequired,
  setEditingRow: PropTypes.func.isRequired,
  hostId: PropTypes.number.isRequired,
  editHostsPermission: PropTypes.bool.isRequired,
};
