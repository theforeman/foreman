import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import { APIActions } from '../APIActions';
import {
  key,
  url,
  params,
  headers,
  payload,
  actionTypes,
} from '../APIFixtures';

const fixtures = {
  'should call the API get action': () =>
    APIActions.get({ key, url, params, headers, payload, actionTypes }),
  'should call the API post action': () =>
    APIActions.post({ key, url, params, headers, payload, actionTypes }),
  'should call the API put action': () =>
    APIActions.put({ key, url, params, headers, payload, actionTypes }),
  'should call the API patch action': () =>
    APIActions.patch({ key, url, params, headers, payload, actionTypes }),
  'should call the API delete action': () =>
    APIActions.delete({ key, url, headers, payload, actionTypes }),
};

describe('API actions', () => {
  testActionSnapshotWithFixtures(fixtures);
});
