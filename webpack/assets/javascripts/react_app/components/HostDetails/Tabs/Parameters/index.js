import PropTypes from 'prop-types';
import React from 'react';
import { STATUS } from '../../../../constants';
import { ParametersTable } from './ParametersTable';
import SkeletonLoader from '../../../common/SkeletonLoader';
import { useAPI } from '../../../../common/hooks/API/APIHooks';
import { HOST_PARAM } from './ParametersConstants';

const ParametersTab = ({ response, status, hostName }) => {
  const {
    all_parameters: allParameters,
    permissions: { edit_hosts: editHosts } = {},
    id: hostId,
  } = response;
  const { response: inheritedParams } = useAPI(
    'get',
    `/api/hosts/${hostName}/inherited_parameters`
  );
  const inheritedParamsNames = inheritedParams?.params?.map(
    param => param.name
  );
  return (
    <SkeletonLoader status={status} skeletonProps={{ count: 5 }}>
      {allParameters?.length && inheritedParams !== undefined && (
        <ParametersTable
          status={status}
          hostId={hostId}
          allParameters={allParameters.map(param => {
            if (
              param.associated_type === HOST_PARAM &&
              inheritedParamsNames?.length &&
              inheritedParamsNames.includes(param.name)
            ) {
              return { ...param, override: true };
            }
            return param;
          })}
          editHostsPermission={editHosts}
        />
      )}
    </SkeletonLoader>
  );
};

ParametersTab.propTypes = {
  hostName: PropTypes.string,
  status: PropTypes.string,
  response: PropTypes.shape({
    parameters: PropTypes.array,
    all_parameters: PropTypes.array,
    permissions: PropTypes.shape({
      edit_hosts: PropTypes.bool,
    }),
    id: PropTypes.number,
  }),
};

ParametersTab.defaultProps = {
  hostName: undefined,
  status: STATUS.PENDING,
  response: {
    parameters: undefined,
    all_parameters: undefined,
    permissions: { edit_hosts: false },
  },
};

export default ParametersTab;
