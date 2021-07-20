import APIHelper from '../../../redux/API/API';
import { renderHook } from '@testing-library/react-hooks';
import { useDangerouslyLegacy } from './LegacyLoaderHook';
import {
  basicHtml,
  multipleHtml,
  chosenElement,
} from './LegacyLoaderHook.fixtures.js';
import { STATUS } from '../../../constants';
import { API_OPERATIONS } from '../../../redux/API';
jest.mock('axios');
jest.mock('../../../redux/API/API');

it('should return html', async () => {
  APIHelper.get.mockResolvedValue(basicHtml);
  const { result, waitForNextUpdate } = renderHook(() =>
    useDangerouslyLegacy(API_OPERATIONS.GET, '/some-url')
  );
  expect(result.current.status).toEqual(STATUS.PENDING);
  await waitForNextUpdate();
  expect(result.current.html).toEqual(basicHtml.data);
  expect(result.current.status).toEqual(STATUS.RESOLVED);
});

it('should choose dom element', async () => {
  APIHelper.get.mockResolvedValue(multipleHtml);
  const { result, waitForNextUpdate } = renderHook(() =>
    useDangerouslyLegacy(API_OPERATIONS.GET, '/some-url', {
      chosenElement: 'keep',
    })
  );
  expect(result.current.status).toEqual(STATUS.PENDING);
  await waitForNextUpdate();
  expect(result.current.html).toEqual(chosenElement);
  expect(result.current.status).toEqual(STATUS.RESOLVED);
});

it('should remove dom element', async () => {
  APIHelper.get.mockResolvedValue(multipleHtml);
  const { result, waitForNextUpdate } = renderHook(() =>
    useDangerouslyLegacy(API_OPERATIONS.GET, '/some-url', {
      elementsToRemove: ["delete"],
    })
  );
  expect(result.current.status).toEqual(STATUS.PENDING);
  await waitForNextUpdate();
  expect(result.current.html).toContain('visible');
  expect(result.current.html).not.toContain('remove');
  expect(result.current.status).toEqual(STATUS.RESOLVED);
});
