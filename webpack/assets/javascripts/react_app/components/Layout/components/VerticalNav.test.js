import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import { hasTaxonomiesMock } from '../Layout.fixtures';

import VerticalNav from './VerticalNav';

const fixtures = {
  'render VerticalNav': {
    activeMenu: hasTaxonomiesMock.activeMenu,
    changeActiveMenu: () => {},
    history: hasTaxonomiesMock.history,
    items: hasTaxonomiesMock.items,
  },
};

describe('VerticalNav', () => {
  describe('rendering', () => {
    const spy = jest.spyOn(console, 'error').mockImplementation();

    testComponentSnapshotsWithFixtures(VerticalNav, fixtures);

    // Currently expect a prop warning since VerticalNav passes an object into NavExpandable title prop although it expects a string. This will change soon.
    expect(spy).toHaveBeenCalledTimes(1);
    // eslint-disable-next-line
    expect(console.error.mock.calls[0][0]).toEqual(expect.stringContaining('Warning: Failed prop type: Invalid prop `title` of type `object` supplied to `NavExpandable`, expected `string`'));
    spy.mockRestore();
  });
});
