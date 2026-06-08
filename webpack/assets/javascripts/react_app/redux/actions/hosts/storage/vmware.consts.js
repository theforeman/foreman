export const HARD_DISK_LABEL = 'Hard disk';
export const vmwareDiskNameForIndex = oneBasedIndex =>
  `${HARD_DISK_LABEL} ${oneBasedIndex}`;

export const defaultControllerAttributes = 
  {
    type: 'VirtualLsiLogicController',
  }

const _defaultDiskAttributes = {
  sizeGb: 10,
  datastore: '',
  storagePod: '',
  thin: false,
  eagerZero: false,
  name: vmwareDiskNameForIndex(1),
  mode: 'persistent',
};

export const getDefaultDiskAttributes = _defaultDiskAttributes;
