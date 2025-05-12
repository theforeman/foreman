import { APIActions } from '../../../../redux/API';
import { foremanUrl } from '../../../../common/helpers';

export const BULK_ASSIGN_TAXONOMY_KEY = 'BULK_ASSIGN_TAXONOMY';
export const bulkAssignTaxonomy = (params, handleSuccess, handleError) => {
  const url = foremanUrl(`/api/v2/hosts/bulk/assign_taxonomy`);
  return APIActions.put({
    key: BULK_ASSIGN_TAXONOMY_KEY,
    url,
    handleSuccess,
    handleError,
    params,
  });
};

export const ORGANIZATION_KEY = 'ORGANIZATION';
export const LOCATION_KEY = 'LOCATION';

export const fetchOrganizations = () => {
  const url = foremanUrl('/api/v2/organizations');
  return APIActions.get({
    key: ORGANIZATION_KEY,
    url,
    params: {
      per_page: 'all',
    },
  });
};

export const fetchLocations = () => {
  const url = foremanUrl('/api/v2/locations');
  return APIActions.get({
    key: LOCATION_KEY,
    url,
    params: {
      per_page: 'all',
    },
  });
};

export default bulkAssignTaxonomy;
