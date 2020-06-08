import React from 'react';
import PropTypes from 'prop-types';
import { Col, HelpBlock, FormGroup, FormControl } from 'patternfly-react';

import { translate as __ } from '../../../common/I18n';
import { arraySelection } from '../../SettingsTable/SettingsTableHelpers';
import { renderOptions } from '../../common/forms/SelectHelpers';

const SettingValueField = ({ setting, form, field }) => {
  const { selectValues } = setting;

  let inputField = <FormControl {...field} />;

  const error = form.errors && form.errors.value;

  if (selectValues) {
    inputField = (
      <FormControl {...field} componentClass="select">
        {renderOptions(arraySelection(setting) || selectValues)}
      </FormControl>
    );
  }

  if (setting.settingsType === 'boolean') {
    inputField = (
      <FormControl {...field} componentClass="select">
        <option value>{__('Yes')}</option>
        <option value={false}>{__('No')}</option>
      </FormControl>
    );
  }

  if (setting.settingsType === 'array') {
    inputField = <FormControl {...field} componentClass="textarea" />;
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
