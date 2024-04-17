import { actionTypeGenerator } from '../../../redux/API/APIActionTypeGenerator';
import { translate as __ } from '../../../common/I18n';
import { urlWithSearch } from '../../../common/urlHelpers';
import { foremanUrl } from '../../../common/helpers';

export const searchLink = ({ query, message, baseUrl }) => ({
  children: message,
  href: urlWithSearch(baseUrl, query),
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
