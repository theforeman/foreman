import { actionTypeGenerator } from '../../../redux/API/APIActionTypeGenerator';
import { translate as __ } from '../../../common/I18n';
import { urlWithSearch } from '../../../common/urlHelpers';
import { foremanUrl } from '../../../common/helpers';

export const searchLink = ({ query, message, baseUrl }) => ({
  children: message,
  href: urlWithSearch(baseUrl, query),
});

export const bulkActionTaxonomyParams = ({
  organizationId,
  locationId,
} = {}) => ({
  ...(organizationId != null ? { organization_id: organizationId } : {}),
  ...(locationId != null ? { location_id: locationId } : {}),
});

export const buildBulkRequestBody = ({
  fetchBulkParams,
  organizationId,
  locationId,
  includedSearch,
  ...params
}) => ({
  included: {
    search: includedSearch || fetchBulkParams(),
  },
  ...bulkActionTaxonomyParams({ organizationId, locationId }),
  ...params,
});

export const failedHostsToastParams = ({
  message,
  failed_host_ids: failedHostIds,
  key,
}) => {
  const { FAILURE } = actionTypeGenerator(key);
  const toastParams = {
    type: 'danger',
    message,
    key: FAILURE,
  };
  if (failedHostIds) {
    const query = `id ^ (${failedHostIds.join(',')})`;
    toastParams.link = searchLink({
      query,
      message: __('Failed hosts'),
      baseUrl: foremanUrl('new/hosts'),
    });
  }

  return toastParams;
};

export const bulkErrorToastParams = (error, key) => {
  const fallback = error?.message || __('Unexpected error occurred.');
  const apiError = error?.response?.data?.error;
  const isObject = apiError && typeof apiError === 'object';
  let message = isObject ? apiError.message : apiError;

  if (isObject && Array.isArray(apiError.failed_hosts)) {
    const reasons = [
      ...new Set(
        apiError.failed_hosts.map(host => host.error).filter(Boolean)
      ),
    ];
    if (reasons.length > 0) {
      message = [message, ...reasons].filter(Boolean).join(' ');
    }
  }

  return failedHostsToastParams({
    message: message || fallback,
    failed_host_ids: isObject ? apiError.failed_host_ids : undefined,
    key,
  });
};
