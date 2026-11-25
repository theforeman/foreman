import { actionTypeGenerator } from '../../../redux/API/APIActionTypeGenerator';
import { getAPIErrorMessage } from '../../../redux/API/APIHelpers';
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
  const baseMessage =
    getAPIErrorMessage(error) || __('Unexpected error occurred.');
  const apiError = error?.response?.data?.error;
  const isObject = apiError && typeof apiError === 'object';

  const hostReasons =
    isObject && Array.isArray(apiError.failed_hosts)
      ? [
          ...new Set(
            apiError.failed_hosts.map(host => host.error).filter(Boolean)
          ),
        ]
      : [];
  const message =
    hostReasons.length > 0
      ? [baseMessage, ...hostReasons].join(' ')
      : baseMessage;

  return failedHostsToastParams({
    message,
    failed_host_ids: isObject ? apiError.failed_host_ids : undefined,
    key,
  });
};
