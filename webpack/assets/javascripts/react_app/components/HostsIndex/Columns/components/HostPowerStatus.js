import React, { useContext } from 'react';
import { useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { useAPI } from '../../../../common/hooks/API/APIHooks';
import { selectAPIResponse } from '../../../../redux/API/APISelectors';
import { HostsPowerRefreshContext } from '../../HostsPowerRefreshContext';
import PowerStatusIcon from '../../../HostDetails/DetailsCard/PowerStatus/PowerStatusIcon';

const HostPowerStatus = ({ hostName }) => {
  const { refreshId } = useContext(HostsPowerRefreshContext);
  const key = `HOST_POWER_STATUS_${hostName}_${refreshId}`;
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

  return (
    <span title={tooltipText}>
      <PowerStatusIcon state={state} responseStatus={response.status} />
    </span>
  );
};

HostPowerStatus.propTypes = {
  hostName: PropTypes.string.isRequired,
};

export default HostPowerStatus;
