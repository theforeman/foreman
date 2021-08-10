import { act } from '@testing-library/react-hooks';
import { useAPI } from './APIHooks';
import APIHelper from '../../../redux/API/API';
import { renderHookWithRedux } from '../testHelper';
import {
  API_TEST_KEY,
  resultFromGOT,
  resultsFromLOTR,
} from './APIHooks.fixtures';
jest.mock('axios');
jest.mock('../../../redux/API/API');
jest.unmock('seamless-immutable');

it('should use default url', async () => {
  APIHelper.get.mockResolvedValue(resultFromGOT);
  const { result, waitForNextUpdate } = renderHookWithRedux(() =>
    useAPI('get', '/lotr')
  );
  await waitForNextUpdate();

  expect(result.current.response.results).toEqual(resultFromGOT.data.results);
  expect(result.current.key).toBeDefined();
});

it('shuold use the given key', async () => {
  APIHelper.get.mockResolvedValue(resultsFromLOTR);
  const { result, waitForNextUpdate } = renderHookWithRedux(() =>
    useAPI('get', '/got', { key: API_TEST_KEY })
  );
  expect(result.current.response).toEqual({});

  await waitForNextUpdate();
  expect(result.current.key).toEqual(API_TEST_KEY);
});

it('shuold update APIOptions', async () => {
  const spy = jest.spyOn(APIHelper, 'get');
  APIHelper.get.mockResolvedValue(resultsFromLOTR);
  const { result } = renderHookWithRedux(() =>
    useAPI('get', '/lotr', { params: { a: 'a param' } })
  );

  await act(async () => {
    result.current.setAPIOptions(prevOptions => ({
      ...prevOptions,
      params: { a: 'updated param' },
    }));
  });

  expect(spy).toHaveBeenLastCalledWith('/lotr', {}, { a: 'updated param' });
});
