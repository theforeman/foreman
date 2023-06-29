import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Tr, Td } from '@patternfly/react-table';
import { TimesIcon, CheckIcon } from '@patternfly/react-icons';
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

export const EditParametersTableRow = ({
  param,
  rowIndex,
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
          successToast: () => sprintf(__('Created parameter %s'), name),
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
          successToast: () => sprintf(__('Edited parameter %s'), name),
          ...APIActionsProps,
        })
      );
    }
  };
  return (
    <Tr ouiaId={`edit-parameters-table-row-${rowIndex}`} key={rowIndex}>
      <Td dataLabel={columnNames.name}>
        <Form>
          <FormGroup
            validated={name.includes(' ') ? 'error' : null}
            helperTextInvalid={__("Name can't contain spaces")}
          >
            <TextInput
              ouiaId={`edit-parameters-table-row-name-${rowIndex}`}
              validated={name.includes(' ') ? 'error' : null}
              aria-label={`${param.name} name text`}
              value={name}
              onChange={setName}
              label={null}
            />
          </FormGroup>
        </Form>
      </Td>
      <Td dataLabel={columnNames.type}>
        <Select
          ouiaId={`edit-parameters-table-row-type-${rowIndex}`}
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
      </Td>
      <Td dataLabel={columnNames.value}>
        <>
          {type === 'boolean' ? (
            <Select
              ouiaId={`edit-parameters-table-row-boolean-${rowIndex}`}
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
              ouiaId={`edit-parameters-table-row-value-${rowIndex}`}
              aria-label={`${param.name} value text`}
              value={typeof value === 'object' ? JSON.stringify(value) : value}
              onChange={setValue}
              label={null}
              type={isHide ? 'password' : 'text'}
              rows={1}
              autoResize
            />
          )}
          <Checkbox
            ouiaId={`edit-parameters-table-row-hide-${rowIndex}`}
            label={__('Hide value')}
            isChecked={isHide}
            onChange={setIsHide}
            id="hide value checkbox"
          />
        </>
      </Td>
      <Td dataLabel={columnNames.source}>{param.associated_type}</Td>
      {editHostsPermission && (
        <Td isActionCell className="parameters-row-actions">
          <>
            <Tooltip content={__('Cancel')}>
              <Button
                ouiaId={`edit-parameters-table-row-cancel-${rowIndex}`}
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
                ouiaId={`edit-parameters-table-row-submit-${rowIndex}`}
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
        </Td>
      )}
      <RowActions
        hostId={hostId}
        param={param}
        editHostsPermission={editHostsPermission}
      />
    </Tr>
  );
};

EditParametersTableRow.propTypes = {
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
  isNew: PropTypes.bool,
};

EditParametersTableRow.defaultProps = { isNew: false };
