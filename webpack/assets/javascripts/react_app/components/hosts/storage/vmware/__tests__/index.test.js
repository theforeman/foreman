import { controllersToJsonString } from '../index';

describe('controllersToJsonString', () => {
  it('removes the key parameter from volumes', () => {
    const volumes = [
      {
        thin: true,
        name: 'Hard disk',
        mode: 'persistent',
        controllerKey: 1000,
        size: 10485760,
        sizeGb: 10,
        key: 'bd3ebb40-4862-11e8-9aaf-adeef3f61848',
      },
    ];

    const controllers = [
      {
        type: 'VirtualLsiLogicController',
        key: 1000,
      },
    ];

    const expectedJson =
      '{"scsiControllers":[{"type":"VirtualLsiLogicController","key":1000}],"volumes":[{"thin":true,"name":"Hard disk","mode":"persistent","controllerKey":1000,"size":10485760,"sizeGb":10}]}';

    expect(controllersToJsonString(controllers, volumes)).toEqual(expectedJson);
  });
});
