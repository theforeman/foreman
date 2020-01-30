import React from 'react';
import PropTypes from 'prop-types';

const SettingName = ({ setting }) => (
  <React.Fragment>{setting.fullName}</React.Fragment>
);

SettingName.propTypes = {
  setting: PropTypes.object.isRequired,
};

export default SettingName;
