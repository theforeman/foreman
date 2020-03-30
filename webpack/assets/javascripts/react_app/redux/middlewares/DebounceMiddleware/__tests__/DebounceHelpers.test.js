import { withDebounce } from '../DebounceHelpers';
import { action, actionWithDebounce, debounce } from '../DebounceFixtures';

describe('Debounce Helpers', () => {
  it('return withDebounce modified action', () => {
    expect(withDebounce(action)).toEqual(actionWithDebounce);
    expect(withDebounce(action, debounce)).toEqual(actionWithDebounce);
  });
});
