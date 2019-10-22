import { DEFAULT_POLLING } from './APIConstants';

export const startAPIInterval = (APIRequest, ms) => {
  const pollingMiliSec = typeof ms === 'number' ? ms : DEFAULT_POLLING;
  return setInterval(APIRequest, pollingMiliSec);
};

export const stopAPIInterval = id => {
  clearInterval(id);
};

export const registeredPollingException = key =>
  new Error(
    `There is already a polling process running and registered for: ${key}. Clear it or use another key if you wish to create another polling process.`
  );

export const unregisteredPollingException = key =>
  new Error(`Can't find a registered polling process for: ${key}`);
