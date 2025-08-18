import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Button, Flex, FlexItem, Icon } from '@patternfly/react-core';
import { PencilAltIcon } from '@patternfly/react-icons';
import SettingValueEdit from './SettingValueEdit';
import SettingValue from './SettingValue';
import { formatEncryptedValue } from '../SettingsTableHelpers';

const SettingValueCell = ({ setting, index }) => {
  const [editingRow, setEditingRow] = useState(false);
  const [settingData, setSettingData] = useState(setting);
  const updateSetting = newValue => {
    // newValue might be the raw value or a full setting object from the server
    const updatedSetting =
      newValue && typeof newValue === 'object' && newValue.id
        ? { ...settingData, ...newValue }
        : { ...settingData, value: newValue };

    // Ensure the displayed value respects encryption based on the updated flag
    const displaySetting = {
      ...updatedSetting,
      value: formatEncryptedValue(updatedSetting),
    };

    setSettingData(displaySetting);
    setEditingRow(false);
  };

  return (
    <>
      {editingRow ? (
        <SettingValueEdit setting={settingData} updateSetting={updateSetting} />
      ) : (
        <Flex
          justifyContent={{ default: 'justifyContentSpaceBetween' }}
          alignItems={{ default: 'alignItemsCenter' }}
        >
          <FlexItem className="setting-value">
            <SettingValue setting={settingData} />
          </FlexItem>
          <FlexItem>
            {!setting.readonly && (
              <Button
                onClick={() => setEditingRow(true)}
                variant="plain"
                ouiaId={`edit-row-${index}-icon`}
                id={setting.name}
              >
                <Icon>
                  <PencilAltIcon />
                </Icon>
              </Button>
            )}
          </FlexItem>
        </Flex>
      )}
    </>
  );
};

SettingValueCell.propTypes = {
  setting: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
};

export default SettingValueCell;
