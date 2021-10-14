import { selectAPIResponse } from '../../../redux/API/APISelectors';
import { selectComponentByWeight } from '../../common/Slot/SlotSelectors';
import { SUPPORTED_ERRORS, API_OPTIONS } from './constants';

export const selectKebabItems = () =>
  selectComponentByWeight('host-details-kebab');

export const selectBuildErrors = state =>
  selectAPIResponse(state, API_OPTIONS.key)?.errors;

export const selectBuildErrorsTree = state => {
  const buildErrors = selectBuildErrors(state);
  return buildErrors
    ? Object.entries(buildErrors)
        .map(([key, value]) => ({
          name: SUPPORTED_ERRORS[key],
          id: key,
          children: value.map((item, idx) => ({
            name: item.message,
            id: `${key}-${idx}`,
          })),
        }))
        ?.filter(error => error.children.length)
    : [];
};

export const selectNoErrorState = state => {
  const buildErrors = selectBuildErrors(state);
  const isEmptyArray = currentValue => currentValue.length === 0;
  return buildErrors ? Object.values(buildErrors).every(isEmptyArray) : false;
};
