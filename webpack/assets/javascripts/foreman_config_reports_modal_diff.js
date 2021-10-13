import store from './react_app/redux';

import * as diffModalActions from './react_app/components/ConfigReports/DiffModal/DiffModalActions';

export const showDiff = (log) => {
  store.dispatch(
    diffModalActions.createDiff(log.dataset.diff, log.dataset.title)
  );
};
