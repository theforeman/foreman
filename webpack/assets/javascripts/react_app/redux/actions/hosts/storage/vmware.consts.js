export const defaultConrollerAttributes = {
  type: 'ParaVirtualSCSIController'
};

const _defaultDiskAttributes = () => ({
  sizeGb: 10,
  datastore: '',
  storagePod: '',
  thin: false,
  eagerZero: false,
  name: __('Hard disk'),
  mode: 'persistent'
});

export const getDefaultDiskAttributes = _defaultDiskAttributes;
