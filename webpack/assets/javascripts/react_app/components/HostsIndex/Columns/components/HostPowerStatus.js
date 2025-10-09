import React from 'react';
import { useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import {
  PowerOffIcon as PowerOnIcon,
  OffIcon as PowerOffIcon,
  UnknownIcon,
} from '@patternfly/react-icons';
import { Icon } from '@patternfly/react-core';
import { useAPI } from '../../../../common/hooks/API/APIHooks';
import SkeletonLoader from '../../../common/SkeletonLoader';
import { selectAPIResponse } from '../../../../redux/API/APISelectors';
import { STATUS } from '../../../../constants';

const HostPowerStatus = ({ hostName }) => {
  const key = `HOST_POWER_STATUS_${hostName}`;
  const existingResponse = useSelector(state => selectAPIResponse(state, key));
  const useExistingResponse = !!existingResponse.state;
  const response = useAPI(
    useExistingResponse ? null : 'get',
    `/api/v2/hosts/${hostName}/power`,
    {
      key,
    }
  );
  if (useExistingResponse) {
    response.response = existingResponse;
  }
  const { state, statusText, title } = response.response || {};
  const tooltipText = state === 'na' ? `${title} - ${statusText}` : title;
  let powerIcon = (
    <Icon>
      <UnknownIcon />
    </Icon>
  );
  const moveItALittleUp = { position: 'relative', top: '-0.1em' };
  const green = 'var(--pf-v5-global--palette--green-300)';
  const disabledGray = 'var(--pf-v5-global--disabled-color--200)';
  switch (state) {
    case 'on':
      powerIcon = (
        <span style={{ ...moveItALittleUp, color: green }}>
          <Icon>
            <PowerOnIcon title={tooltipText} />
          </Icon>
        </span>
      );
      break;
    case 'off':
      powerIcon = (
        <span style={{ ...moveItALittleUp }}>
          <Icon>
            <PowerOffIcon title={tooltipText} />
          </Icon>
        </span>
      );
      break;
    default:
      powerIcon = (
        <span style={{ ...moveItALittleUp, color: disabledGray }}>
          <Icon>
            <UnknownIcon title={tooltipText} />
          </Icon>
        </span>
      );
  }
  return (
    <SkeletonLoader status={response.status ?? STATUS.PENDING}>
      {powerIcon}
    </SkeletonLoader>
  );
};

HostPowerStatus.propTypes = {
  hostName: PropTypes.string.isRequired,
};

export default HostPowerStatus;
