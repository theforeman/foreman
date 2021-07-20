import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { Dropdown, DropdownToggle, DropdownItem } from '@patternfly/react-core';

import { capitalize, foremanUrl } from '../../../common/helpers';
import { useAPI } from '../../../common/hooks/API/APIHooks';
import PowerStatusIcon from './PowerStatusIcon';
import { POWER_REQUEST_OPTIONS, SUPPORTED_POWER_STATES } from './constant';
import { changeHostPower } from './actions';
import './styles.scss';

const PowerStatusDropDown = ({ hostID, hasPowerPermission }) => {
  const powerURL = hostID && foremanUrl(`/api/hosts/${hostID}/power`);
  const {
    response: { state: currentState, statusText, title },
    status: responseStatus,
  } = useAPI('get', powerURL, POWER_REQUEST_OPTIONS);

  const dispatch = useDispatch();
  const [isOpen, setOpen] = useState(false);
  const changePowerHandler = targetState => {
    dispatch(changeHostPower(targetState, hostID));
  };
  const dropdownItems = () =>
    SUPPORTED_POWER_STATES.map(state => (
      <DropdownItem
        onClick={() => changePowerHandler(state)}
        isDisabled={state === currentState}
        key={state}
      >
        {capitalize(state)}
      </DropdownItem>
    ));

  const onDropdownSelect = event => setOpen(false);
  const onToggle = open => setOpen(open);
  return (
    <Dropdown
      isOpen={isOpen}
      open={isOpen}
      onSelect={onDropdownSelect}
      isPlain
      dropdownItems={dropdownItems()}
      toggle={
        <DropdownToggle
          isDisabled={!hasPowerPermission || currentState === 'na'}
          onToggle={onToggle}
          aria-label="power dropdown"
        >
          <PowerStatusIcon
            state={currentState}
            statusText={statusText}
            title={title}
            responseStatus={responseStatus}
          />
        </DropdownToggle>
      }
    />
  );
};

PowerStatusDropDown.propTypes = {
  hasPowerPermission: PropTypes.bool,
  hostID: PropTypes.number,
};

PowerStatusDropDown.defaultProps = {
  hasPowerPermission: false,
  hostID: undefined,
};

export default PowerStatusDropDown;
