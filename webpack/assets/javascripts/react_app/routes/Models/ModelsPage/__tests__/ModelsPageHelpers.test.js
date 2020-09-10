import { pickSort, buildQuery } from '../ModelsPageHelpers';

import {
  querySort,
  pickedQuery,
  queryParams,
  resultParams,
  stateParams,
  stateFactory,
} from './ModelsPage.fixtures';

describe('pickSort', () => {
  it('should pick sort from query', () => {
    expect(pickSort(querySort, {})).toStrictEqual(pickedQuery);
  });

  it('should pick sort from state', () => {
    const state = stateFactory({ sort: pickedQuery });
    expect(pickSort({}, state)).toStrictEqual(pickedQuery);
  });
});

describe('buildQuery', () => {
  it('should return params from query if present', () => {
    expect(buildQuery(queryParams, {})).toStrictEqual(resultParams);
  });

  it('should return params from state', () => {
    const state = stateFactory(stateParams);
    expect(buildQuery({}, state)).toStrictEqual(resultParams);
  });
});
