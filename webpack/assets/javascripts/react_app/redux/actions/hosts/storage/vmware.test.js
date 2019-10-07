import {
  datastoresUrl,
  storagePodsUrl,
  basicConfig,
  initAction,
  changeClusterAction,
  changeToEmptyClusterAction,
  state1,
} from './vmware.fixtures';

import * as actions from './vmware';

describe('vmware storage hosts actions', () => {
  describe('initController', () => {
    it('initializes the container', () => {
      const dispatch = jest.fn();
      const dispatcher = actions.initController(
        basicConfig,
        'cluster',
        null,
        null
      );

      dispatcher(dispatch);

      expect(dispatch).toHaveBeenCalledTimes(3);
      expect(dispatch).toHaveBeenCalledWith(initAction);
    });

    it('doesnt fetch storages without cluster', () => {
      const dispatch = jest.fn();
      const dispatcher = actions.initController(basicConfig, null, null, null);
      const initActionWoCluster = initAction;
      initActionWoCluster.payload.cluster = null;

      dispatcher(dispatch);

      expect(dispatch).toHaveBeenCalledTimes(1);
      expect(dispatch).toHaveBeenCalledWith(initActionWoCluster);
    });
  });

  describe('changeCluster', () => {
    it('changes the cluster and refetches the storages', () => {
      const dispatch = jest.fn();
      const dispatcher = actions.changeCluster('newCluster');

      dispatcher(dispatch, () => state1);

      expect(dispatch).toHaveBeenCalledTimes(3);
      expect(dispatch).toHaveBeenCalledWith(changeClusterAction);
    });

    it('doesnt fetch the storages if the cluster is empty', () => {
      const dispatch = jest.fn();
      const dispatcher = actions.changeCluster('');
      dispatcher(dispatch, () => state1);
      expect(dispatch).toHaveBeenCalledTimes(1);
      expect(dispatch).toHaveBeenCalledWith(changeToEmptyClusterAction);
    });
  });

  describe.each([
    ['fetchDatastores', datastoresUrl],
    ['fetchStoragePods', storagePodsUrl],
  ])('%s', (actionName, url) => {
    it('makes the ajax request to the right url', () => {
      const action = actions[actionName](url, 'cluster');
      expect(action).toMatchSnapshot();
    });
  });
});
