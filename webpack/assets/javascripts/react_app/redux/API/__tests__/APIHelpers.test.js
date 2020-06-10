import API from '../API';
import { API_OPERATIONS } from '../APIConstants';
import {
  getApiMethodByActionType,
  getApiResponse,
  isAPIAction,
} from '../APIHelpers';
import { url, headers, params } from '../APIFixtures';

jest.mock('../API');

describe('API helpers', () => {
  it('should return the right method based on a API_OPERATIONS type', () => {
    Object.keys(API_OPERATIONS).forEach(type => {
      expect(getApiMethodByActionType(API_OPERATIONS[type])).toEqual(
        type.toLowerCase()
      );
    });
  });

  it('should call API get', async () => {
    API.get.mockImplementation(async () => jest.fn());
    await getApiResponse({ type: API_OPERATIONS.GET, url, headers, params });
    expect(API.get).toBeCalledWith(url, headers, params);
  });

  it('should call API post', async () => {
    API.post.mockImplementation(async () => jest.fn());
    await getApiResponse({ type: API_OPERATIONS.POST, url, headers, params });
    expect(API.post).toBeCalledWith(url, params, headers);
  });

  it('should call API put', async () => {
    API.put.mockImplementation(async () => jest.fn());
    await getApiResponse({ type: API_OPERATIONS.PUT, url, headers, params });
    expect(API.put).toBeCalledWith(url, params, headers);
  });

  it('should call API patch', async () => {
    API.patch.mockImplementation(async () => jest.fn());
    await getApiResponse({ type: API_OPERATIONS.PATCH, url, headers, params });
    expect(API.patch).toBeCalledWith(url, params, headers);
  });

  it('should call API delete', async () => {
    API.delete.mockImplementation(async () => jest.fn());
    await getApiResponse({ type: API_OPERATIONS.DELETE, url, headers });
    expect(API.delete).toBeCalledWith(url, headers);
  });

  it('should call isAPIAction', async () => {
    Object.keys(API_OPERATIONS).forEach(type => {
      expect(isAPIAction({ type: API_OPERATIONS[type] })).toBeTruthy();
    });
  });
});
