import { APIActions } from '../../../../redux/API';
import { foremanUrl } from '../../../../common/helpers';

export const BULK_CHANGE_OWNER_KEY = 'BULK_CHANGE_OWNER';
export const bulkChangeOwner = (params, handleSuccess, handleError) => {
  const url = foremanUrl(`/api/v2/hosts/bulk/change_owner`);
  return APIActions.put({
    key: BULK_CHANGE_OWNER_KEY,
    url,
    handleSuccess,
    handleError,
    params,
  });
};

export const USER_KEY = 'USER_KEY';
export const USERGROUP_KEY = 'USERGROUP_KEY';

export const fetchUsers = () => {
  const url = foremanUrl('/api/users');
  return APIActions.get({
    key: USER_KEY,
    url,
    params: {
      per_page: 'all',
    },
  });
};

export const fetchUsergroups = () => {
  // eslint-disable-next-line spellcheck/spell-checker
  const url = foremanUrl('/api/usergroups');
  return APIActions.get({
    key: USERGROUP_KEY,
    url,
    params: {
      per_page: 'all',
    },
  });
};

export default bulkChangeOwner;
