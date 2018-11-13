import store from './react_app/redux';
import { showDiff } from './foreman_config_reports_modal_diff';
import { createDiff } from './react_app/components/ConfigReports/DiffModal/DiffModalActions';

jest.unmock('./foreman_config_reports_modal_diff');
jest.mock('./react_app/redux', () => ({ dispatch: jest.fn() }));
jest.mock('./react_app/components/ConfigReports/DiffModal/DiffModalActions');

const log = {
  dataset: { diff: '---diff---', title: 'log1' },
};

describe('foreman_config_reports_modal_diff', () => {
  beforeEach(() => jest.resetAllMocks());

  describe('createDiff', () => {
    it('should actions', () => {
      const {
        dataset: { diff, title },
      } = log;
      showDiff(log);
      expect(createDiff).toHaveBeenCalledWith(diff, title);
      expect(store.dispatch).toHaveBeenCalledTimes(1);
    });
  });
});
