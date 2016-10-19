jest.unmock('./dispatcher');

import dispatcher from './dispatcher';

describe('dispatcher', () => {
  it('exists', () => {
    expect(dispatcher).not.toBeUndefined();
  });
});

