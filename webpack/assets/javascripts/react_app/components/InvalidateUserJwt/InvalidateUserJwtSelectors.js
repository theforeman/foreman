import { INVALIDATE_USER_JWT } from './InvalidateUserJwtConstants';
import { selectAPIStatus } from '../../redux/API/APISelectors';

export const selectStatus = state =>
  selectAPIStatus(state, INVALIDATE_USER_JWT);
