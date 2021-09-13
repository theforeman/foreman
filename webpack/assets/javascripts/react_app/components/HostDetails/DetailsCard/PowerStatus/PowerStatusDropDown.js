import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import {
  Dropdown,
  DropdownToggle,
  DropdownItem,
  Tooltip,
} from '@patternfly/react-core';

import { foremanUrl } from '../../../../common/helpers';
import { useAPI } from '../../../../common/hooks/API/APIHooks';
import { translate as __ } from '../../../../common/I18n';
import PowerStatusIcon from './PowerStatusIcon';
import {
  POWER_REQUEST_OPTIONS,
  BASE_POWER_STATES,
  SUPPORTED_POWER_STATES,
} from './constants';
import { changeHostPower } from './actions';
import { openConfirmModal } from '../../../ConfirmModal';

import '../styles.scss';

const PowerStatusDropDown = ({ hostID, hasPowerPermission, isBmc }) => {
  const powerURL = foremanUrl(`/api/hosts/${hostID}/power`);
  const {
    response: { state: currentState, title, statusText },
    status: responseStatus,
  } = useAPI('get', powerURL, POWER_REQUEST_OPTIONS);

  const dispatch = useDispatch();
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
      >
        {supportedPowerStates[state]}
      </DropdownItem>
    ));
  };

  const onDropdownSelect = event => setOpen(false);
  const onToggle = open => setOpen(open);
  return (
    <Tooltip content={statusText || title}>
      <Dropdown
        isOpen={isOpen}
        onSelect={onDropdownSelect}
        isPlain
        dropdownItems={dropdownItems()}
        toggle={
          <DropdownToggle
            isDisabled={!hasPowerPermission || currentState === 'na'}
            onToggle={onToggle}
          >
            <PowerStatusIcon
              state={currentState}
              title={title}
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
  hostID: PropTypes.string.isRequired,
  isBmc: PropTypes.bool,
};

PowerStatusDropDown.defaultProps = {
  hasPowerPermission: false,
  isBmc: false,
};

export default PowerStatusDropDown;
