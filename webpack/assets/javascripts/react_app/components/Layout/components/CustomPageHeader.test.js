import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import CustomPageHeader from './CustomPageHeader';

const fixtures = {
  'render CustomPageHeader': {
    className: '',
    logo: null,
    logoProps: null,
    logoComponent: 'a',
    toolbar: null,
    avatar: null,
    topNav: null,
    isNavOpen: true,
    role: undefined,
    showNavToggle: false,
    onNavToggle: () => undefined,
    afterNavToggle: () => undefined,
    'aria-label': 'Global navigation',
    contextSelector: null,
  },
};

describe('CustomPageHeader', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(CustomPageHeader, fixtures));
});
