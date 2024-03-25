import { selectAPIResponse } from '../../redux/API/APISelectors';
import { RENDER_STATUSES_KEY } from './RenderStatusesConstants';

export const selectRenderStatuses = state =>
  selectAPIResponse(state, RENDER_STATUSES_KEY)?.results || [];

export const selectTotalRenderStatuses = state =>
  selectAPIResponse(state, RENDER_STATUSES_KEY)?.subtotal || 0;
