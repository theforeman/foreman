import { APIActions } from '../../../../redux/API';
import { foremanUrl } from '../../../../common/helpers';
import {
  BULK_ASSIGN_ORGANIZATION_KEY,
  BULK_ASSIGN_LOCATION_KEY,
  ORGANIZATION_KEY,
  LOCATION_KEY,
} from './BulkAssignTaxonomyConstants';

export const bulkAssignOrganization = (params, handleSuccess, handleError) => {
  const url = foremanUrl(`/api/v2/hosts/bulk/assign_organization`);
  return APIActions.put({
    key: BULK_ASSIGN_ORGANIZATION_KEY,
    url,
    handleSuccess,
    handleError,
    params,
  });
};

export const bulkAssignLocation = (params, handleSuccess, handleError) => {
  const url = foremanUrl(`/api/v2/hosts/bulk/assign_location`);
  return APIActions.put({
    key: BULK_ASSIGN_LOCATION_KEY,
    url,
    handleSuccess,
    handleError,
    params,
  });
};

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
