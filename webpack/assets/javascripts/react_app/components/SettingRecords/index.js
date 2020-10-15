import React, { useEffect } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';

import { loadSettingRecords } from './SettingRecordsActions';
import reducer from './SettingRecordsReducer';

export const reducers = {
  settingRecords: reducer,
};

const SettingRecords = ({ settings }) => {
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(loadSettingRecords(settings));
  });

  return <React.Fragment />;
};

SettingRecords.propTypes = {
  settings: PropTypes.object,
};

SettingRecords.defaultProps = {
  settings: {},
};

export default SettingRecords;
