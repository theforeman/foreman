import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Button, TextInput, Flex, FlexItem } from '@patternfly/react-core';
import { PencilAltIcon, CheckIcon, TimesIcon } from '@patternfly/react-icons';

import { APIActions } from '../../redux/API';
import { sprintf, translate as __ } from '../../common/I18n';

export const InlineEdit = ({
  name,
  defaultValue,
  hostName,
  editPermission,
}) => {
  const [value, setValue] = useState(defaultValue);
  const [isEditing, setIsEditing] = useState(false);

  const handleInputChange = newValue => {
    setValue(newValue);
  };

  const dispatch = useDispatch();
  const handleSave = () => {
    setIsEditing(false);

    dispatch(
      APIActions.put({
        url: `/api/hosts/${hostName}`,
        key: `${hostName}-${name}-EDIT`,
        params: {
          [name]: value,
        },
        successToast: () => sprintf(__('%s saved'), name),
      })
    );
  };
  const handleCancel = () => {
    setIsEditing(false);
    setValue(defaultValue);
  };
  return (
    <Flex flexWrap={{ default: 'nowrap' }}>
      {isEditing ? (
        <>
          <FlexItem
            grow={{ default: 'grow' }}
            spacer={{ default: 'spacerNone' }}
          >
            <TextInput
              ouiaId={`input-${name}`}
              value={value}
              type="text"
              onChange={handleInputChange}
              aria-label="Editable text input"
            />
          </FlexItem>
          <FlexItem spacer={{ default: 'spacerNone' }}>
            <Button
              variant="plain"
              aria-label="Save edits"
              ouiaId={`save-${name}`}
              onClick={handleSave}
            >
              <CheckIcon />
            </Button>
          </FlexItem>
          <FlexItem spacer={{ default: 'spacerNone' }}>
            <Button
              variant="plain"
              aria-label="Cancel edits"
              ouiaId={`cancel-edit-${name}`}
              onClick={handleCancel}
            >
              <TimesIcon />
            </Button>
          </FlexItem>
        </>
      ) : (
        <>
          <FlexItem
            spacer={{ default: 'spacerNone' }}
            grow={{ default: 'grow' }}
          >
            <div className="pf-c-inline-edit__value">{value}</div>
          </FlexItem>
          {editPermission && (
            <FlexItem spacer={{ default: 'spacerNone' }}>
              <Button
                ouiaId={`edit-${name}`}
                variant="plain"
                aria-label="Edit"
                onClick={() => setIsEditing(true)}
              >
                <PencilAltIcon />
              </Button>
            </FlexItem>
          )}
        </>
      )}
    </Flex>
  );
};

InlineEdit.propTypes = {
  name: PropTypes.string.isRequired,
  defaultValue: PropTypes.string,
  hostName: PropTypes.string.isRequired,
  editPermission: PropTypes.bool,
};

InlineEdit.defaultProps = {
  defaultValue: '',
  editPermission: false,
};
