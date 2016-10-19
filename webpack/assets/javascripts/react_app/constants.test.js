jest.unmock('./constants');

import {ACTIONS} from './constants';

describe('exists', () => {
  it('RECEIVED_STATISTICS action exists', () => {
    expect(ACTIONS.RECEIVED_STATISTICS).not.toBeUndefined();
  });
});
