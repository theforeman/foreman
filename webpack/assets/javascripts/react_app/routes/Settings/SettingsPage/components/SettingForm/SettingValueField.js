import React from 'react';
import PropTypes from 'prop-types';

import { Col, HelpBlock, FormGroup } from 'patternfly-react';

import SettingValueArraySelect from './SettingValueArraySelect';
import SettingValueHashSelect from './SettingValueHashSelect';
import SettingValueBoolean from './SettingValueBoolean';
import InputField from '../../../../../components/common/forms/InputField';

const SettingValueField = ({ setting, form, field }) => {
  const { selectValues } = setting;
  let inputField = <InputField field={field} />;

  const error = form.errors && form.errors.value;

  if (selectValues && selectValues.kind === 'array') {
    inputField = <SettingValueArraySelect field={field} setting={setting} />;
  }

  if (selectValues && selectValues.kind === 'hash') {
    inputField = <SettingValueHashSelect field={field} setting={setting} />;
  }

  if (setting.settingsType === 'boolean') {
    inputField = <SettingValueBoolean field={field} setting={setting} />;
  }

  if (setting.settingsType === 'array') {
    inputField = <InputField field={field} componentClass="textarea" />;
  }

  const helpBlock = (
    <HelpBlock>
      <span className="error-msg">{error}</span>
    </HelpBlock>
  );

  return (
    <React.Fragment>
      <FormGroup className={error ? 'has-error' : ''}>
        <Col md={10}>{inputField}</Col>
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
