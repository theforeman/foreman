import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../common/I18n';

const SettingName = ({ setting }) => (
  <React.Fragment>{setting.fullName && __(setting.fullName)}</React.Fragment>
);

SettingName.propTypes = {
  setting: PropTypes.object.isRequired,
};

export default SettingName;
