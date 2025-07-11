import { shallowRenderComponentWithFixtures } from '../../../../common/testHelpers';
import ActionsBar from '../index';
import { 
  baseProps, 
  noPowerProps, 
  noPermissionProps 
} from './ActionsBar.fixtures';

// Mock the required external dependencies
jest.mock('../../../../../foreman_navigation', () => ({
  visit: jest.fn(),
}));

jest.mock('../../../../Root/Context/ForemanContext', () => ({
  useForemanSettings: () => ({ destroyVmOnHostDelete: false }),
  useForemanHostsPageUrl: () => '/hosts',
}));

jest.mock('react-redux', () => ({
  useSelector: jest.fn(() => []),
  useDispatch: () => jest.fn(),
  connect: jest.fn(() => (component) => component),
}));

const fixtures = {
  'renders ActionsBar with all permissions (including power)': baseProps,
  'renders ActionsBar without power permissions': noPowerProps,
  'renders ActionsBar without any permissions': noPermissionProps,
};

describe('ActionsBar', () => {
  describe('rendering', () => {
    const components = shallowRenderComponentWithFixtures(ActionsBar, fixtures);
    components.forEach(({ description, component }) => {
      it(description, () => {
        expect(component).toMatchSnapshot();
      });
    });
  });
});
