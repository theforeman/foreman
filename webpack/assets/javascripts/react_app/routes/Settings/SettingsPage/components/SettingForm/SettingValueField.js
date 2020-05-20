import React from 'react';
import PropTypes from 'prop-types';

import { Col, HelpBlock, FormGroup } from 'patternfly-react';

import InputFactory from '../../../../../components/common/forms/InputFactory';

const SettingValueField = ({ setting, form, field }) => {
  const error = form.errors && form.errors.value;

  const arraySelectProps = settingModel =>
    settingModel.selectValues && settingModel.selectValues.kind === 'array'
      ? { type: 'arraySelect', field, model: settingModel }
      : null;

  const hashSelectProps = settingModel =>
    settingModel.selectValues && settingModel.selectValues.kind === 'hash'
      ? { type: 'hashSelect', field, model: settingModel }
      : null;

  const boolSelectProps = settingModel =>
    settingModel.settingsType === 'boolean'
      ? { type: 'boolSelect', field }
      : null;

  const arrayProps = settingModel =>
    settingModel.settingsType === 'array'
      ? { ...field, componentClass: 'textarea' }
      : null;

  const inputProps = settingModel => ({ ...field });

  const fieldProps = (propSelectors, model) =>
    propSelectors.reduce((memo, propFn) => {
      if (memo) {
        return memo;
      }

      return propFn(model);
    }, null);

  const factoryProps = fieldProps(
    [
      arraySelectProps,
      hashSelectProps,
      boolSelectProps,
      arrayProps,
      inputProps,
    ],
    setting
  );

  const helpBlock = (
    <HelpBlock>
      <span className="error-msg">{error}</span>
    </HelpBlock>
  );

  return (
    <React.Fragment>
      <FormGroup className={error ? 'has-error' : ''}>
        <Col md={10}>
          <InputFactory {...factoryProps} />
        </Col>
        {error && helpBlock}
      </FormGroup>
    </React.Fragment>
  );
};

SettingValueField.propTypes = {
  setting: PropTypes.object.isRequired,
  form: PropTypes.object.isRequired,
  field: PropTypes.object.isRequired,
};

export default SettingValueField;
