import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import { get } from '../APIActions';
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
    get({ key, url, params, headers, payload, actionTypes }),
};

describe('API actions', () => {
  testActionSnapshotWithFixtures(fixtures);
});
