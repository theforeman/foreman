import { APIActions } from '../../../../redux/API';
import { foremanUrl } from '../../../../common/helpers';

export const BULK_REASSIGN_HOSTGROUP_KEY = 'BULK_REASSIGN_HOSTGROUP_KEY';
export const bulkReassignHostgroups = (params, handleSuccess, handleError) => {
  const url = foremanUrl(`/api/v2/hosts/bulk/reassign_hostgroup`);
  return APIActions.put({
    key: BULK_REASSIGN_HOSTGROUP_KEY,
    url,
    handleSuccess,
    handleError,
    params,
  });
};

export const HOSTGROUP_KEY = 'HOSTGROUP_KEY';

export const fetchHostgroups = () => {
  const url = foremanUrl('/api/v2/hostgroups');
  return APIActions.get({
    key: HOSTGROUP_KEY,
    url,
    params: {
      per_page: 'all',
    },
  });
};

export default bulkReassignHostgroups;
