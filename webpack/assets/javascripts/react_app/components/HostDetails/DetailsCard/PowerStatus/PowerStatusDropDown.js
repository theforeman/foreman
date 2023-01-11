import PropTypes from 'prop-types';
import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  Dropdown,
  DropdownToggle,
  DropdownItem,
  Tooltip,
} from '@patternfly/react-core';

import { get } from '../../../../redux/API';
import { foremanUrl } from '../../../../common/helpers';
import { translate as __ } from '../../../../common/I18n';
import PowerStatusIcon from './PowerStatusIcon';
import {
  POWER_REQUEST_OPTIONS,
  BASE_POWER_STATES,
  SUPPORTED_POWER_STATES,
  POWER_REQURST_KEY,
} from './constants';
import { changeHostPower } from './actions';
import { openConfirmModal } from '../../../ConfirmModal';
import {
  selectState,
  selectTitle,
  selectResponseStatus,
} from './PowerStatusSelectors';

import '../styles.scss';

const PowerStatusDropDown = ({
  hostID,
  hasPowerPermission,
  isBmc,
  iconSize,
}) => {
  const dispatch = useDispatch();

  const key = `${POWER_REQURST_KEY}_${hostID}`;
  const currentState = useSelector(store => selectState(store, key));
  const title = useSelector(store => selectTitle(store, key));
  const responseStatus = useSelector(store => selectResponseStatus(store, key));

  useEffect(() => {
    dispatch(
      get(
        {
          key,
          url: foremanUrl(`/api/hosts/${hostID}/power`),
        },
        POWER_REQUEST_OPTIONS
      )
    );
  }, [hostID, key, dispatch]);

  const [isOpen, setOpen] = useState(false);
  const changePowerHandler = targetState => {
    dispatch(
      openConfirmModal({
        title: __('Power Status'),
        message: __('This will change the host power status, are you sure?'),
        isWarning: true,
        onConfirm: () => dispatch(changeHostPower(targetState, hostID)),
      })
    );
  };
  const dropdownItems = () => {
    const supportedPowerStates = isBmc
      ? SUPPORTED_POWER_STATES
      : BASE_POWER_STATES;

    return Object.keys(supportedPowerStates).map(state => (
      <DropdownItem
        onClick={() => changePowerHandler(state)}
        isDisabled={state === currentState}
        key={state}
        ouiaId={`dropdown-${state}`}
      >
        {supportedPowerStates[state]}
      </DropdownItem>
    ));
  };

  const onDropdownSelect = event => setOpen(false);
  const onToggle = open => setOpen(open);
  return (
    <Tooltip content={title}>
      <Dropdown
        ouiaId="power-status-dropdown"
        isOpen={isOpen}
        onSelect={onDropdownSelect}
        isPlain
        dropdownItems={dropdownItems()}
        toggle={
          <DropdownToggle
            ouiaId="power-status-dropdown-toggle"
            isDisabled={!hasPowerPermission || currentState === 'na'}
            onToggle={onToggle}
          >
            <PowerStatusIcon
              state={currentState}
              size={iconSize}
              responseStatus={responseStatus}
            />
          </DropdownToggle>
        }
      />
    </Tooltip>
  );
};

PowerStatusDropDown.propTypes = {
  hasPowerPermission: PropTypes.bool,
  hostID: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  isBmc: PropTypes.bool,
  iconSize: PropTypes.string,
};

PowerStatusDropDown.defaultProps = {
  hasPowerPermission: false,
  isBmc: false,
  iconSize: 'md',
};

export default PowerStatusDropDown;
