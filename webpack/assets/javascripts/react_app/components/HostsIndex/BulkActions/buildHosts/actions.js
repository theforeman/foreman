import { APIActions } from '../../../../redux/API';
import { foremanUrl } from '../../../../common/helpers';

export const HOST_BUILD_KEY = 'HOST_BUILD_KEY';
export const bulkBuildHosts = (params, handleSuccess, handleError) => {
  const url = foremanUrl(`/api/v2/hosts/bulk/build`);
  return APIActions.put({
    key: HOST_BUILD_KEY,
    url,
    successToast: response => response.data.message,
    handleSuccess,
    handleError,
    params,
  });
};

export default bulkBuildHosts;
