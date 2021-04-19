import { INVALIDATE_USER_JWT } from './InvalidateUserJwtConstants';
import { foremanUrl } from '../../../foreman_tools';
// import * as APIActions from '../../redux/API';
import { APIActions } from '../../redux/API';

export const invalidateJwtAction = id =>
  APIActions.delete({
    key: INVALIDATE_USER_JWT,
    url: foremanUrl(`/api/v2/users/${id}/invalidate_jwts`),
  });
