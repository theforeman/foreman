import { selectAPIStatus } from '../../redux/API/APISelectors';

import { COMMON_PARAM_FORM } from './CommonParamFormConsts';

export const selectApiStatus = state =>
  selectAPIStatus(state, COMMON_PARAM_FORM);
