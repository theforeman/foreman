import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { CheckIcon, TimesIcon } from '@patternfly/react-icons';
import {
  Button,
  Flex,
  FlexItem,
  FormGroup,
  FormHelperText,
  FormSelect,
  FormSelectOption,
  HelperText,
  HelperTextItem,
  TextArea,
  TextInput,
} from '@patternfly/react-core';

import { useDispatch } from 'react-redux';

import classNames from 'classnames';
import { sprintf, translate as __ } from '../../../common/I18n';
import { arraySelection, renderPF5Options } from '../SettingsTableHelpers';
import { useForemanSetContext } from '../../../Root/Context/ForemanContext';

import { APIActions } from '../../../redux/API';

export const SETTING_UPDATE_PATH = '/api/settings/:id';
export const SETTING_NEW_HOSTS_PAGE = 'new_hosts_page';

const getString = value => {
  if (value === null) return '';
  return value;
};

const SettingValueEdit = ({ setting, updateSetting }) => {
  const dispatch = useDispatch();
  const setContext = useForemanSetContext();

  const { selectValues } = setting;
  const cssClasses = classNames({ 'masked-input': setting.encrypted });

  const [loading, setLoading] = useState(false);
  const [errMsg, setErrMsg] = useState(null);
  const [value, setNewValue] = useState(getString(setting.value));

  const handleChange = (_event, data) => {
    setNewValue(data);
  };

  const handleKeyDown = event => {
    if (event.key === 'Enter') {
      handleSubmit();
    } else if (event.key === 'Escape') {
      updateSetting(setting.value);
    }
  };

  const errorCallback = () => {
    setLoading(false);
  };

  const successCallback = submitValue => {
    updateSetting(submitValue);

    if (setting.name === SETTING_NEW_HOSTS_PAGE) {
      const bool = value === 'true';
      setContext(context => {
        context.metadata.UISettings.displayNewHostsPage = bool;
        return context;
      });
    }
  };

  const handleSubmit = () => {
    if (value !== '' && value.trim() === '') {
      setErrMsg(__('Invalid value'));
      return;
    }

    setLoading(true);
    setErrMsg(null);

    let splitValue = value;
    if (setting && setting.settingsType === 'array') {
      splitValue =
        value === '' || value.length === 0
          ? []
          : value.split(',').map(item => item.trim());
    }

    const request = {
      url: SETTING_UPDATE_PATH.replace(':id', setting.id),
      params: { ...setting, value: splitValue },
      key: `${setting.id}-EDIT`,
      handleSuccess: () => successCallback(splitValue),
      handleError: errorCallback,
      errorToast: error => {
        const msg =
          error.response?.data?.error?.message ||
          // eslint-disable-next-line camelcase
          error.response?.data?.error?.full_messages ||
          error.response?.data?.error?.errors?.value[0] ||
          error.response?.data?.errors?.value[0];
        setErrMsg(msg);
        return `${__('Error updating setting')}: ${msg}`;
      },
      successToast: () => sprintf('updated setting %s', setting.fullName),
    };

    dispatch(APIActions.put(request));
  };

  let inputField = (
    <TextInput
      validated={errMsg ? 'error' : 'default'}
      id={`setting-input-${setting.name}`}
      ouiaId={`setting-input-${setting.name}`}
      value={value}
      onChange={handleChange}
      onKeyDown={handleKeyDown}
      isDisabled={loading}
      className={cssClasses}
    />
  );

  if (selectValues) {
    inputField = (
      <FormSelect
        validated={errMsg ? 'error' : 'default'}
        id={`setting-select-${setting.name}`}
        ouiaId={`setting-select-${setting.name}`}
        aria-label="Multiple select"
        className={cssClasses}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        isDisabled={loading}
        value={value}
      >
        {renderPF5Options(arraySelection(setting) || selectValues)}
      </FormSelect>
    );
  }

  if (setting.settingsType === 'boolean') {
    inputField = (
      <FormSelect
        validated={errMsg ? 'error' : 'default'}
        id={`setting-select-${setting.name}`}
        ouiaId={`setting-select-${setting.name}`}
        aria-label="Boolean select"
        className={cssClasses}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        isDisabled={loading}
        value={value}
      >
        <FormSelectOption value label={__('Yes')} />
        <FormSelectOption value={false} label={__('No')} />
      </FormSelect>
    );
  } else if (setting.settingsType === 'array') {
    inputField = (
      <TextArea
        validated={errMsg ? 'error' : 'default'}
        id={`setting-textarea-${setting.name}`}
        onKeyDown={handleKeyDown}
        onChange={handleChange}
        value={value}
        isDisabled={loading}
        className={cssClasses}
      />
    );
  }

  const encryptedHelp = (
    <HelperTextItem>
      {__(
        'This setting is encrypted. Empty input field is displayed instead of the setting value.'
      )}
    </HelperTextItem>
  );

  return (
    <Flex
      justifyContent={{ default: 'justifyContentSpaceBetween' }}
      flexWrap={{ default: 'nowrap' }}
      spaceItems={{ default: 'spaceItemsNone' }}
    >
      <FlexItem className="pf-u-max-width-100 pf-v5-u-w-100">
        <FormGroup fieldId="setting-input">
          {inputField}
          <FormHelperText>
            <HelperText>
              <HelperTextItem variant="error">
                {errMsg}
                {setting.encrypted && encryptedHelp}
              </HelperTextItem>
            </HelperText>
          </FormHelperText>
        </FormGroup>
      </FlexItem>
      <FlexItem>
        <Flex
          justifyContent={{ default: 'justifyContentEnd' }}
          flexWrap={{ default: 'nowrap' }}
          spaceItems={{ default: 'spaceItemsNone' }}
        >
          <FlexItem>
            <Button
              onClick={() => updateSetting(setting.value)}
              variant="plain"
              isDisabled={loading}
              ouiaId="cancel-edit-btn"
            >
              <TimesIcon />
            </Button>
          </FlexItem>
          <FlexItem>
            <Button
              onClick={() => handleSubmit()}
              variant="plain"
              isDisabled={loading}
              ouiaId="submit-edit-btn"
            >
              <CheckIcon />
            </Button>
          </FlexItem>
        </Flex>
      </FlexItem>
    </Flex>
  );
};

SettingValueEdit.propTypes = {
  setting: PropTypes.object.isRequired,
  updateSetting: PropTypes.func.isRequired,
};

export default SettingValueEdit;
