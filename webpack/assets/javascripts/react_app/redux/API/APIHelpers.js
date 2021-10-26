import { API_OPERATIONS } from './APIConstants';
import { API } from './';

export const getApiMethodByActionType = type => type.substring(4).toLowerCase();

export const getApiResponse = async ({ type, url, headers, params }) => {
  const method = getApiMethodByActionType(type);
  switch (method) {
    case 'get':
      return API[method](url, headers, params);
    case 'delete':
      return API[method](url, headers);
    default:
      return API[method](url, params, headers);
  }
};

export const defaultErrorToast = error => {
  if (error?.data?.errors) return error.data.errors;
  return `${error.status} - ${error.statusText}`;
};

export const isAPIAction = ({ type }) =>
  Object.values(API_OPERATIONS).includes(type);
