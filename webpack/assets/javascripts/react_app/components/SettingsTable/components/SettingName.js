import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../common/I18n';

const SettingName = ({ setting }) => (
  <>{setting.fullName ? __(setting.fullName) : setting.name}</>
);

SettingName.propTypes = {
  setting: PropTypes.object.isRequired,
};

export default SettingName;
