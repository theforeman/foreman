import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Tr, Td, TableText } from '@patternfly/react-table';
import {
  TimesIcon,
  CheckIcon,
  PencilAltIcon,
  FlagIcon,
} from '@patternfly/react-icons';
import {
  SelectVariant,
  Select,
  SelectOption,
  Button,
  TextInput,
  TextArea,
  Checkbox,
  FormGroup,
  Form,
  Tooltip,
} from '@patternfly/react-core';
import { APIActions } from '../../../../redux/API';
import { sprintf, translate as __ } from '../../../../common/I18n';
import { HOST_PARAM, columnNames, typeOptions } from './ParametersConstants';
import { updateHost } from '../../ActionsBar/actions';
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

export const ParametersTableRow = ({
  param,
  rowIndex,
  editingRow,
  setEditingRow,
  hostId,
  editHostsPermission,
  isNew,
}) => {
  const [name, setName] = useState(param.name);
  const [type, setType] = useState(param.parameter_type);
  const [value, setValue] = useState(param.value);
  const [selectIsOpen, setSelectIsOpen] = useState(false);
  const [selectValueIsOpen, setSelectValueIsOpen] = useState(false);
  const [isHide, setIsHide] = useState(param['hidden_value?']);

  const dispatch = useDispatch();

  const APIActionsProps = {
    errorToast: ({ response }) =>
      // eslint-disable-next-line camelcase
      response?.data?.error?.full_messages || response?.data?.error?.message,
    handleSuccess: () => {
      dispatch(updateHost(hostId));
    },
  };
  const onSubmit = () => {
    if (isNew || param.associated_type !== HOST_PARAM) {
      dispatch(
        APIActions.post({
          url: `/api/hosts/${hostId}/parameters/`,
          key: 'NEW-PARAM',
          params: {
            name,
            value,
            parameter_type: type,
            hidden_value: isHide,
          },
          successToast: () =>
            sprintf(__('Parameter %s has been created successfully'), name),
          ...APIActionsProps,
        })
      );
    } else {
      dispatch(
        APIActions.put({
          url: `/api/hosts/${hostId}/parameters/${param.id}`,
          key: `${param.id}-EDIT`,
          params: {
            name,
            value,
            parameter_type: type,
            hidden_value: isHide,
          },
          successToast: () =>
            sprintf(__('Parameter %s has been edited successfully'), name),
          ...APIActionsProps,
        })
      );
    }
  };
  const onCancel = () => {
    setName(param.name);
    setType(param.parameter_type);
    setValue(param.value);
    setIsHide(false);
    setSelectIsOpen(false);
  };
  const isEditing = isNew || editingRow === rowIndex;
  return (
    <Tr key={rowIndex}>
      <Td dataLabel={columnNames.name}>
        {isEditing ? (
          <Form>
            <FormGroup
              validated={name.includes(' ') ? 'error' : null}
              helperTextInvalid={__("Name can't contain spaces")}
            >
              <TextInput
                validated={name.includes(' ') ? 'error' : null}
                aria-label={`${param.name} name text`}
                value={name}
                onChange={setName}
                label={null}
              />
            </FormGroup>
          </Form>
        ) : (
          <>
            {param.override && (
              <>
                <Tooltip content={__('Overridden')}>
                  <FlagIcon />{' '}
                </Tooltip>
              </>
            )}
            {name}
          </>
        )}
      </Td>
      <Td dataLabel={columnNames.type}>
        {isEditing ? (
          <Select
            variant={SelectVariant.single}
            aria-label={`Select ${param.name} type`}
            onToggle={setSelectIsOpen}
            selections={type}
            isOpen={selectIsOpen}
            onSelect={(event, selection) => {
              setSelectIsOpen(false);
              setType(selection);
            }}
          >
            {typeOptions.map((option, index) => (
              <SelectOption key={index} value={option} />
            ))}
          </Select>
        ) : (
          type
        )}
      </Td>
      <Td dataLabel={columnNames.value}>
        {isEditing ? (
          <>
            {type === 'boolean' ? (
              <Select
                variant={SelectVariant.single}
                aria-label={`Select ${param.name} value`}
                onToggle={setSelectValueIsOpen}
                selections={value.toString()}
                isOpen={selectValueIsOpen}
                onSelect={(event, selection) => {
                  setSelectValueIsOpen(false);
                  setValue(selection === 'true');
                }}
              >
                <SelectOption value="true" />
                <SelectOption value="false" />
              </Select>
            ) : (
              <TextArea
                aria-label={`${param.name} value text`}
                value={
                  typeof value === 'object' ? JSON.stringify(value) : value
                }
                onChange={setValue}
                label={null}
                type={isHide ? 'password' : 'text'}
                rows={1}
                autoResize
              />
            )}
            <Checkbox
              label={__('Hide value')}
              isChecked={isHide}
              onChange={setIsHide}
              id="hide value checkbox"
            />
          </>
        ) : (
          <TableText wrapModifier="truncate">{getValue(param)}</TableText>
        )}
      </Td>
      <Td dataLabel={columnNames.source}>{param.associated_type}</Td>
      {editHostsPermission && (
        <Td isActionCell className="parameters-row-actions">
          {isEditing ? (
            <>
              <Tooltip content={__('Cancel')}>
                <Button
                  aria-label={`cancel ${param.name} edit`}
                  variant="plain"
                  onClick={() => {
                    setEditingRow(-1);
                    setName(param.name);
                    setType(param.parameter_type);
                    setValue(param.value);
                  }}
                >
                  <TimesIcon />
                </Button>
              </Tooltip>
              <Tooltip content={__('Submit edit')}>
                <Button
                  aria-label={`submit ${param.name} edit`}
                  variant="plain"
                  onClick={() => {
                    setEditingRow(-1);
                    onSubmit();
                  }}
                  isDisabled={name.includes(' ')}
                >
                  <CheckIcon />
                </Button>
              </Tooltip>
            </>
          ) : (
            <Tooltip
              content={
                param.associated_type === HOST_PARAM
                  ? __('edit')
                  : __('override')
              }
            >
              <Button
                aria-label={
                  param.associated_type === HOST_PARAM
                    ? `edit ${param.name}`
                    : `override ${param.name}`
                }
                variant="plain"
                onClick={() => {
                  setEditingRow(rowIndex);
                  onCancel();
                }}
              >
                <PencilAltIcon />
              </Button>
            </Tooltip>
          )}
        </Td>
      )}
      <RowActions hostId={hostId} param={param} />
    </Tr>
  );
};

ParametersTableRow.propTypes = {
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
  editingRow: PropTypes.number.isRequired,
  setEditingRow: PropTypes.func.isRequired,
  hostId: PropTypes.number.isRequired,
  editHostsPermission: PropTypes.bool.isRequired,
  isNew: PropTypes.bool,
};

ParametersTableRow.defaultProps = { isNew: false };
