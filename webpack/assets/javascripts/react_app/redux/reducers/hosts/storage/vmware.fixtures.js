import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  controllers: [],
  volumes: [],
});

export const controllerAttributes = {
  type: 'ParaVirtualSCSIController',
};

export const diskAttributes = {
  datastore: '',
  eagerZero: false,
  mode: 'persistent',
  name: 'Hard disk',
  sizeGb: 10,
  storagePod: '',
  thin: false,
};

export const diskKey = '5124c2d1-339b-11e9-98f5-5f761412a4c2';

const _generateController = key =>
  Immutable({
    controllers: [
      {
        key,
        type: 'ParaVirtualSCSIController',
      },
    ],
    volumes: [
      {
        controllerKey: key,
        datastore: '',
        eagerZero: false,
        key: diskKey,
        mode: 'persistent',
        name: 'Hard disk',
        sizeGb: 10,
        storagePod: '',
        thin: false,
      },
    ],
  });

export const stateWithController = _generateController(1000);
export const stateWithRemovedController = _generateController(1001);
