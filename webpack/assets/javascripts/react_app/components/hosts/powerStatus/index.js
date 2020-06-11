import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { useSelector, useDispatch } from 'react-redux';
import PowerStatus from './PowerStatus';
import { get } from '../../../redux/API';
import { HOST_POWER_STATUS } from './PowerStatusConstants';
import { selectState, selectTitle } from './PowerStatusSelectors';

const ConnectedPowerStatus = ({ id, url }) => {
  const key = `${HOST_POWER_STATUS}_${id}`;
  const state = useSelector(store => selectState(store, key));
  const title = useSelector(store => selectTitle(store, key));
  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(get({ key, url }));
  }, [url, key, dispatch]);

  return <PowerStatus state={state} title={title} />;
};

ConnectedPowerStatus.propTypes = {
  id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  url: PropTypes.string.isRequired,
};

export default ConnectedPowerStatus;
