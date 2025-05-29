import { APIActions } from '../../../../redux/API';
import { foremanUrl } from '../../../../common/helpers';

export const BULK_DISASSOCIATE_KEY = 'BULK_DISASSOCIATE';
export const bulkDisassociate = (params, handleSuccess, handleError) => {
  const url = foremanUrl(`/api/v2/hosts/bulk/disassociate`);
  return APIActions.put({
    key: BULK_DISASSOCIATE_KEY,
    url,
    handleSuccess,
    handleError,
    params,
  });
};

export default bulkDisassociate;
