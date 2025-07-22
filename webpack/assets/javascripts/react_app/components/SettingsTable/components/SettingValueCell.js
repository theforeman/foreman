import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Button, Flex, FlexItem } from '@patternfly/react-core';
import { PencilAltIcon } from '@patternfly/react-icons';
import SettingValueEdit from './SettingValueEdit';
import SettingValue from './SettingValue';
import { formatEncryptedValue } from '../SettingsTableHelpers';

const SettingValueCell = ({ setting, index }) => {
  const [editingRow, setEditingRow] = useState(false);
  const [settingData, setSettingData] = useState(setting);
  const updateSetting = newValue => {
    const newSetting = { ...setting, value: newValue };
    setSettingData({ ...settingData, value: formatEncryptedValue(newSetting) });
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
                <PencilAltIcon />
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
