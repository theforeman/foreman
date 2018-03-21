import { translate as __ } from '../../../../../react_app/common/I18n';

export const defaultControllerAttributes = {
  type: 'ParaVirtualSCSIController',
};

const _defaultDiskAttributes = {
  sizeGb: 10,
  datastore: '',
  storagePod: '',
  thin: false,
  eagerZero: false,
  name: __('Hard disk'),
  mode: 'persistent',
};

export const getDefaultDiskAttributes = _defaultDiskAttributes;
