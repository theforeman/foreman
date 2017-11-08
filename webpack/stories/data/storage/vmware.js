/* eslint-disable */
/* eslint-disable */
export const state1 = {
  config: {
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual'
    },
    diskModeTypes: {
      persistent: 'Persistent',
      independent_persistent: 'Independent - Persistent',
      independent_nonpersistent: 'Independent - Nonpersistent'
    },
    storagePods: {
      StorageCluster: 'StorageCluster (free: 1.01 TB, prov: 7.49 TB, total: 8.5 TB)'
    },
    datastores: {
      'org-esx-55-01-local': 'org-esx-55-01-local (free: 524 GB, prov: 465 GB, total: 924 GB)',
      'org-esx-55-03-local': 'org-esx-55-03-local (free: 898 GB, prov: 165 GB, total: 924 GB)',
      'org-esx-55-04-local': 'org-esx-55-04-local (free: 250 GB, prov: 681 GB, total: 924 GB)',
      'org-esx-55-na01a': 'org-esx-55-na01a (free: 448 GB, prov: 8.56 TB, total: 4 TB)',
      'org-esx-55-na01b': 'org-esx-55-na01b (free: 587 GB, prov: 7.25 TB, total: 4.5 TB)',
      'org-esx-admin-lun-na01b':
        'org-esx-admin-lun-na01b (free: 553 GB, prov: 519 GB, total: 1020 GB)',
      'org-esx-glob-na01a-s': 'org-esx-glob-na01a-s (free: 1.45 TB, prov: 3.49 TB, total: 1.9 TB)',
      'org-esx-glob-na01b-s': 'org-esx-glob-na01b-s (free: 1.37 TB, prov: 2.22 TB, total: 1.9 TB)',
      'org-iso-glob-na01a-s': 'org-iso-glob-na01a-s (free: 341 GB, prov: 134 GB, total: 475 GB)',
      'do-not-use-datastore': 'do-not-use-datastore (free: 462 GB, prov: 12.6 GB, total: 475 GB)',
      'do-not-use-host-prov': 'do-not-use-host-prov (free: 0 Bytes, prov: 973 MB, total: 973 MB)',
      master_iso: 'master_iso (free: 689 GB, prov: 289 GB, total: 973 GB)',
      temp_store: 'temp_store (free: 475 GB, prov: 19.5 MB, total: 475 GB)',
      vsanDatastore: 'vsanDatastore (free: 207 GB, prov: 26.1 GB, total: 233 GB)'
    },
    paramsScope: 'abc'
  },
  volumes: [
    {
      thin: true,
      name: 'Hard disk',
      mode: 'persistent',
      controllerKey: 1000,
      sizeGb: 10
    }
  ],
  controllers: [{ type: 'VirtualLsiLogicController', key: 1000 }]
};

export const state2 = {
  config: {
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual'
    },
    diskModeTypes: {
      persistent: 'Persistent',
      independent_persistent: 'Independent - Persistent',
      independent_nonpersistent: 'Independent - Nonpersistent'
    },
    storagePods: {},
    datastores: {
      'Local-Bulgaria': 'Local-Bulgaria (free: 4.62 TB, prov: 2.34 TB, total: 5.91 TB)',
      'Local-Ironforge': 'Local-Ironforge (free: 1.49 TB, prov: 1.3 TB, total: 2.72 TB)',
      'Local-Jericho': 'Local-Jericho (free: 1.99 TB, prov: 3.02 TB, total: 4.09 TB)',
      'Local-Nightwing': 'Local-Nightwing (free: 591 GB, prov: 182 GB, total: 756 GB)',
      'Local-Supermicro': 'Local-Supermicro (free: 599 GB, prov: 317 GB, total: 917 GB)',
      'NFS-Engineering': 'NFS-Engineering (free: 2.3 TB, prov: 1.74 TB, total: 2.64 TB)'
    },
    paramsScope: 'abc'
  },
  controllers: [
    {
      type: 'VirtualLsiLogicController',
      sharedBus: 'noSharing',
      unitNumber: 7,
      key: 1000
    }
  ],
  volumes: [
    {
      thin: true,
      name: 'Hard disk 1',
      mode: 'persistent',
      controllerKey: 1000,
      serverId: '502e324d-a2af-108b-1e10-b6d9eddfc53a',
      datastore: 'Local-Ironforge',
      id: '6000C297-9a11-998a-fc7c-8125ce9042a3',
      filename:
        '[Local-Ironforge] wanda-marcial.www.somedomain.com/wanda-marcial.www.somedomain.com.vmdk',
      sizeGb: 10,
      key: 2000,
      unitNumber: 0
    }
  ]
};

export const clone = {
  config: {
    vmExists: false,
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual'
    },
    diskModeTypes: {
      persistent: '»Persistent«',
      independent_persistent: '»Independent - Persistent«',
      independent_nonpersistent: '»Independent - Nonpersistent«'
    },
    storagePods: {
      'LX-ESX-SOA-DC1-NoMirror':
        'LX-ESX-SOA-DC1-NoMirror (»free«: 3.82 TB, »prov«: 5.18 TB, »total«: 9 TB)',
      'LX-ESX-SOA-DC2-NoMirror':
        'LX-ESX-SOA-DC2-NoMirror (»free«: 3.79 TB, »prov«: 5.21 TB, »total«: 9 TB)',
      'LX-LAN-MIRROR-DC1': 'LX-LAN-MIRROR-DC1 (»free«: 4.62 TB, »prov«: 14.9 TB, »total«: 19.5 TB)',
      'LX-LAN-MIRROR-DC2': 'LX-LAN-MIRROR-DC2 (»free«: 3.93 TB, »prov«: 8.38 TB, »total«: 12.3 TB)',
      'LX-LAN-NOMIRROR-DC1':
        'LX-LAN-NOMIRROR-DC1 (»free«: 4.94 TB, »prov«: 13.1 TB, »total«: 18 TB)',
      'LX-LAN-NOMIRROR-DC2':
        'LX-LAN-NOMIRROR-DC2 (»free«: 5.96 TB, »prov«: 12 TB, »total«: 17.9 TB)',
      'LX-LAN-NOMIRROR-RZ3':
        'LX-LAN-NOMIRROR-RZ3 (»free«: 597 GB, »prov«: 403 GB, »total«: 1000 GB)',
      'LX-LAN-NOMIRROR-SSD-DC1':
        'LX-LAN-NOMIRROR-SSD-DC1 (»free«: 407 GB, »prov«: 105 GB, »total«: 512 GB)',
      'LX-LAN-NOMIRROR-SSD-DC2':
        'LX-LAN-NOMIRROR-SSD-DC2 (»free«: 386 GB, »prov«: 126 GB, »total«: 512 GB)',
      'LX-Root-LAN-DC1': 'LX-Root-LAN-DC1 (»free«: 2.28 TB, »prov«: 3.22 TB, »total«: 5.5 TB)',
      'LX-Root-LAN-DC2': 'LX-Root-LAN-DC2 (»free«: 2.04 TB, »prov«: 1.96 TB, »total«: 4 TB)',
      LX_LAN_BDA_DC1: 'LX_LAN_BDA_DC1 (»free«: 3.89 TB, »prov«: 1.11 TB, »total«: 5 TB)',
      LX_LAN_DC1_BDABI_NoBackup:
        'LX_LAN_DC1_BDABI_NoBackup (»free«: 8.45 TB, »prov«: 1.55 TB, »total«: 10 TB)',
      LX_LAN_DC1_BDASAS_NoBackup:
        'LX_LAN_DC1_BDASAS_NoBackup (»free«: 14.6 TB, »prov«: 15.9 TB, »total«: 30.5 TB)'
    },
    datastores: {
      ESX_RZ3_1: 'ESX_RZ3_1 (»free«: 346 GB, »prov«: 709 GB, »total«: 500 GB)',
      ESX_RZ3_2: 'ESX_RZ3_2 (»free«: 251 GB, »prov«: 877 GB, »total«: 500 GB)',
      FC0001_LX_LAN_ROOT_PROD_01:
        'FC0001_LX_LAN_ROOT_PROD_01 (»free«: 218 GB, »prov«: 1.13 TB, »total«: 1020 GB)',
      FC0001_LX_LAN_ROOT_PROD_02:
        'FC0001_LX_LAN_ROOT_PROD_02 (»free«: 238 GB, »prov«: 1.74 TB, »total«: 1020 GB)',
      FC0001_LX_LAN_ROOT_PROD_03:
        'FC0001_LX_LAN_ROOT_PROD_03 (»free«: 211 GB, »prov«: 4.39 TB, »total«: 1020 GB)',
      FC0001_LX_LAN_ROOT_PROD_04:
        'FC0001_LX_LAN_ROOT_PROD_04 (»free«: 1.63 TB, »prov«: 2.99 TB, »total«: 2.5 TB)',
      FC0001_LX_LAN_ROOT_PROD_05:
        'FC0001_LX_LAN_ROOT_PROD_05 (»free«: 1.72 TB, »prov«: 6.33 TB, »total«: 2.5 TB)',
      FC0001_LX_LAN_ROOT_PROD_06:
        'FC0001_LX_LAN_ROOT_PROD_06 (»free«: 2.16 TB, »prov«: 2.4 TB, »total«: 2.5 TB)',
      FC0002_LX_LAN_ROOT_PROD_01:
        'FC0002_LX_LAN_ROOT_PROD_01 (»free«: 632 GB, »prov«: 1.37 TB, »total«: 1020 GB)',
      FC0002_LX_LAN_ROOT_PROD_02:
        'FC0002_LX_LAN_ROOT_PROD_02 (»free«: 283 GB, »prov«: 1010 GB, »total«: 1020 GB)',
      FC0002_LX_LAN_ROOT_PROD_03:
        'FC0002_LX_LAN_ROOT_PROD_03 (»free«: 382 GB, »prov«: 2.57 TB, »total«: 1020 GB)',
      FC0002_LX_LAN_ROOT_PROD_04:
        'FC0002_LX_LAN_ROOT_PROD_04 (»free«: 787 GB, »prov«: 1.96 TB, »total«: 1020 GB)',
      LX_ESX_DC1_01_NoMirror:
        'LX_ESX_DC1_01_NoMirror (»free«: 628 GB, »prov«: 2.03 TB, »total«: 2.25 TB)',
      LX_ESX_DC1_NoMirror_08:
        'LX_ESX_DC1_NoMirror_08 (»free«: 623 GB, »prov«: 3.28 TB, »total«: 2.25 TB)',
      LX_ESX_SOA_DC1_01_NoMirror:
        'LX_ESX_SOA_DC1_01_NoMirror (»free«: 1010 GB, »prov«: 2.02 TB, »total«: 3 TB)',
      LX_ESX_SOA_DC1_02_NoMirror:
        'LX_ESX_SOA_DC1_02_NoMirror (»free«: 1.88 TB, »prov«: 1.28 TB, »total«: 3 TB)',
      LX_ESX_SOA_DC1_03_NoMirror:
        'LX_ESX_SOA_DC1_03_NoMirror (»free«: 983 GB, »prov«: 2.04 TB, »total«: 3 TB)',
      LX_ESX_SOA_DC2_01_NoMirror:
        'LX_ESX_SOA_DC2_01_NoMirror (»free«: 1.85 TB, »prov«: 1.2 TB, »total«: 3 TB)',
      LX_ESX_SOA_DC2_02_NoMirror:
        'LX_ESX_SOA_DC2_02_NoMirror (»free«: 983 GB, »prov«: 2.04 TB, »total«: 3 TB)',
      LX_ESX_SOA_DC2_03_NoMirror:
        'LX_ESX_SOA_DC2_03_NoMirror (»free«: 1010 GB, »prov«: 2.02 TB, »total«: 3 TB)',
      LX_ESX_SVC_DC1_21: 'LX_ESX_SVC_DC1_21 (»free«: 254 GB, »prov«: 1.71 TB, »total«: 768 GB)',
      LX_ESX_SVC_DC1_22: 'LX_ESX_SVC_DC1_22 (»free«: 168 GB, »prov«: 1.35 TB, »total«: 768 GB)',
      LX_ESX_SVC_DC1_23: 'LX_ESX_SVC_DC1_23 (»free«: 262 GB, »prov«: 1.86 TB, »total«: 780 GB)',
      LX_ESX_SVC_DC1_24: 'LX_ESX_SVC_DC1_24 (»free«: 250 GB, »prov«: 1.65 TB, »total«: 768 GB)',
      LX_ESX_SVC_DC1_25: 'LX_ESX_SVC_DC1_25 (»free«: 212 GB, »prov«: 1.63 TB, »total«: 780 GB)',
      LX_ESX_SVC_DC1_26: 'LX_ESX_SVC_DC1_26 (»free«: 182 GB, »prov«: 1.53 TB, »total«: 768 GB)',
      LX_ESX_SVC_DC1_BDABI_01:
        'LX_ESX_SVC_DC1_BDABI_01 (»free«: 2.13 TB, »prov«: 3.35 TB, »total«: 2.5 TB)',
      LX_ESX_SVC_DC1_BDABI_02:
        'LX_ESX_SVC_DC1_BDABI_02 (»free«: 2.11 TB, »prov«: 3.13 TB, »total«: 2.5 TB)',
      LX_ESX_SVC_DC1_BDABI_03:
        'LX_ESX_SVC_DC1_BDABI_03 (»free«: 2.07 TB, »prov«: 5.34 TB, »total«: 2.5 TB)',
      LX_ESX_SVC_DC1_BDABI_04:
        'LX_ESX_SVC_DC1_BDABI_04 (»free«: 2.14 TB, »prov«: 1.61 TB, »total«: 2.5 TB)',
      LX_ESX_SVC_DC1_BDASAS_01:
        'LX_ESX_SVC_DC1_BDASAS_01 (»free«: 2 TB, »prov«: 2.72 TB, »total«: 3 TB)',
      LX_ESX_SVC_DC1_BDASAS_02:
        'LX_ESX_SVC_DC1_BDASAS_02 (»free«: 1.5 TB, »prov«: 2.97 TB, »total«: 3 TB)',
      LX_ESX_SVC_DC1_BDASAS_03:
        'LX_ESX_SVC_DC1_BDASAS_03 (»free«: 1.29 TB, »prov«: 10.6 TB, »total«: 3 TB)',
      LX_ESX_SVC_DC1_BDASAS_04:
        'LX_ESX_SVC_DC1_BDASAS_04 (»free«: 2.27 TB, »prov«: 10.4 TB, »total«: 12.5 TB)',
      LX_ESX_SVC_DC1_BDASAS_05:
        'LX_ESX_SVC_DC1_BDASAS_05 (»free«: 2.37 TB, »prov«: 3.44 TB, »total«: 3 TB)',
      LX_ESX_SVC_DC1_BDASAS_06:
        'LX_ESX_SVC_DC1_BDASAS_06 (»free«: 2.5 TB, »prov«: 2.13 TB, »total«: 3 TB)',
      LX_ESX_SVC_DC1_BDASAS_07:
        'LX_ESX_SVC_DC1_BDASAS_07 (»free«: 2.62 TB, »prov«: 565 GB, »total«: 3 TB)',
      LX_ESX_SVC_DC2_17: 'LX_ESX_SVC_DC2_17 (»free«: 233 GB, »prov«: 534 GB, »total«: 768 GB)',
      LX_ESX_SVC_DC2_18: 'LX_ESX_SVC_DC2_18 (»free«: 179 GB, »prov«: 401 GB, »total«: 500 GB)',
      LX_ESX_SVC_DC2_19: 'LX_ESX_SVC_DC2_19 (»free«: 126 GB, »prov«: 811 GB, »total«: 500 GB)',
      LX_ESX_SVC_DC2_20: 'LX_ESX_SVC_DC2_20 (»free«: 167 GB, »prov«: 938 GB, »total«: 500 GB)',
      LX_ESX_SVC_DC2_21: 'LX_ESX_SVC_DC2_21 (»free«: 142 GB, »prov«: 864 GB, »total«: 500 GB)',
      LX_ESX_SVC_DC2_22: 'LX_ESX_SVC_DC2_22 (»free«: 170 GB, »prov«: 1.56 TB, »total«: 500 GB)',
      LX_ESX_SVC_SSD_DC1_1_NoMirror:
        'LX_ESX_SVC_SSD_DC1_1_NoMirror (»free«: 407 GB, »prov«: 760 GB, »total«: 512 GB)',
      LX_ESX_SVC_SSD_DC2_1_NoMirror:
        'LX_ESX_SVC_SSD_DC2_1_NoMirror (»free«: 386 GB, »prov«: 662 GB, »total«: 512 GB)',
      LX_ESX_STD_DC1_01: 'LX_ESX_STD_DC1_01 (»free«: 215 GB, »prov«: 874 GB, »total«: 1020 GB)',
      LX_ESX_STD_DC1_02: 'LX_ESX_STD_DC1_02 (»free«: 158 GB, »prov«: 1.72 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_02_NoMirror:
        'LX_ESX_STD_DC1_02_NoMirror (»free«: 661 GB, »prov«: 1.78 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC1_03: 'LX_ESX_STD_DC1_03 (»free«: 157 GB, »prov«: 1.07 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_03_NoMirror:
        'LX_ESX_STD_DC1_03_NoMirror (»free«: 766 GB, »prov«: 1.72 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC1_04: 'LX_ESX_STD_DC1_04 (»free«: 165 GB, »prov«: 1.97 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_04_NoMirror:
        'LX_ESX_STD_DC1_04_NoMirror (»free«: 731 GB, »prov«: 3.7 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC1_05: 'LX_ESX_STD_DC1_05 (»free«: 220 GB, »prov«: 1.32 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_05_NoMirror:
        'LX_ESX_STD_DC1_05_NoMirror (»free«: 608 GB, »prov«: 1.97 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC1_06: 'LX_ESX_STD_DC1_06 (»free«: 158 GB, »prov«: 1.8 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_06_NoMirror:
        'LX_ESX_STD_DC1_06_NoMirror (»free«: 485 GB, »prov«: 3.13 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC1_07: 'LX_ESX_STD_DC1_07 (»free«: 175 GB, »prov«: 1.25 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_07_NoMirror:
        'LX_ESX_STD_DC1_07_NoMirror (»free«: 557 GB, »prov«: 3.04 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC1_08: 'LX_ESX_STD_DC1_08 (»free«: 115 GB, »prov«: 703 GB, »total«: 500 GB)',
      LX_ESX_STD_DC1_09: 'LX_ESX_STD_DC1_09 (»free«: 177 GB, »prov«: 1.31 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_10: 'LX_ESX_STD_DC1_10 (»free«: 160 GB, »prov«: 1.07 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_11: 'LX_ESX_STD_DC1_11 (»free«: 160 GB, »prov«: 1.05 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_12: 'LX_ESX_STD_DC1_12 (»free«: 157 GB, »prov«: 1.41 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_13: 'LX_ESX_STD_DC1_13 (»free«: 177 GB, »prov«: 1.19 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_14: 'LX_ESX_STD_DC1_14 (»free«: 157 GB, »prov«: 1.53 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_15: 'LX_ESX_STD_DC1_15 (»free«: 161 GB, »prov«: 1010 GB, »total«: 768 GB)',
      LX_ESX_STD_DC1_16: 'LX_ESX_STD_DC1_16 (»free«: 252 GB, »prov«: 940 GB, »total«: 1020 GB)',
      LX_ESX_STD_DC1_17: 'LX_ESX_STD_DC1_17 (»free«: 154 GB, »prov«: 1.88 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_18: 'LX_ESX_STD_DC1_18 (»free«: 186 GB, »prov«: 1.01 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_19: 'LX_ESX_STD_DC1_19 (»free«: 183 GB, »prov«: 1.36 TB, »total«: 768 GB)',
      LX_ESX_STD_DC1_20: 'LX_ESX_STD_DC1_20 (»free«: 117 GB, »prov«: 495 GB, »total«: 500 GB)',
      LX_ESX_STD_DC2_01: 'LX_ESX_STD_DC2_01 (»free«: 100 GB, »prov«: 1.12 TB, »total«: 500 GB)',
      LX_ESX_STD_DC2_01_NoMirror:
        'LX_ESX_STD_DC2_01_NoMirror (»free«: 1.07 TB, »prov«: 2.84 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC2_02: 'LX_ESX_STD_DC2_02 (»free«: 286 GB, »prov«: 913 GB, »total«: 768 GB)',
      LX_ESX_STD_DC2_02_NoMirror:
        'LX_ESX_STD_DC2_02_NoMirror (»free«: 471 GB, »prov«: 3.63 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC2_03: 'LX_ESX_STD_DC2_03 (»free«: 240 GB, »prov«: 801 GB, »total«: 768 GB)',
      LX_ESX_STD_DC2_03_NoMirror:
        'LX_ESX_STD_DC2_03_NoMirror (»free«: 848 GB, »prov«: 1.42 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC2_04: 'LX_ESX_STD_DC2_04 (»free«: 175 GB, »prov«: 605 GB, »total«: 500 GB)',
      LX_ESX_STD_DC2_04_NoMirror:
        'LX_ESX_STD_DC2_04_NoMirror (»free«: 532 GB, »prov«: 2.62 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC2_05: 'LX_ESX_STD_DC2_05 (»free«: 149 GB, »prov«: 1.57 TB, »total«: 500 GB)',
      LX_ESX_STD_DC2_05_NoMirror:
        'LX_ESX_STD_DC2_05_NoMirror (»free«: 852 GB, »prov«: 3.92 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC2_06: 'LX_ESX_STD_DC2_06 (»free«: 169 GB, »prov«: 769 GB, »total«: 500 GB)',
      LX_ESX_STD_DC2_06_NoMirror:
        'LX_ESX_STD_DC2_06_NoMirror (»free«: 817 GB, »prov«: 1.72 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC2_07: 'LX_ESX_STD_DC2_07 (»free«: 160 GB, »prov«: 524 GB, »total«: 500 GB)',
      LX_ESX_STD_DC2_07_NoMirror:
        'LX_ESX_STD_DC2_07_NoMirror (»free«: 694 GB, »prov«: 4.62 TB, »total«: 2.25 TB)',
      LX_ESX_STD_DC2_08: 'LX_ESX_STD_DC2_08 (»free«: 116 GB, »prov«: 414 GB, »total«: 500 GB)',
      LX_ESX_STD_DC2_08_NoMirror:
        'LX_ESX_STD_DC2_08_NoMirror (»free«: 791 GB, »prov«: 1.42 TB, »total«: 2.2 TB)',
      LX_ESX_STD_DC2_09: 'LX_ESX_STD_DC2_09 (»free«: 285 GB, »prov«: 1.03 TB, »total«: 768 GB)',
      LX_ESX_STD_DC2_10: 'LX_ESX_STD_DC2_10 (»free«: 117 GB, »prov«: 938 GB, »total«: 500 GB)',
      LX_ESX_STD_DC2_11: 'LX_ESX_STD_DC2_11 (»free«: 283 GB, »prov«: 1.22 TB, »total«: 768 GB)',
      LX_ESX_STD_DC2_12: 'LX_ESX_STD_DC2_12 (»free«: 273 GB, »prov«: 949 GB, »total«: 768 GB)',
      LX_ESX_STD_DC2_13: 'LX_ESX_STD_DC2_13 (»free«: 173 GB, »prov«: 1.26 TB, »total«: 500 GB)',
      LX_ESX_STD_DC2_14: 'LX_ESX_STD_DC2_14 (»free«: 172 GB, »prov«: 593 GB, »total«: 500 GB)',
      LX_ESX_STD_DC2_15: 'LX_ESX_STD_DC2_15 (»free«: 132 GB, »prov«: 1.1 TB, »total«: 500 GB)',
      LX_ESX_STD_DC2_16: 'LX_ESX_STD_DC2_16 (»free«: 173 GB, »prov«: 511 GB, »total«: 500 GB)'
    }
  },
  volumes: [
    {
      thin: true,
      name: 'Hard disk 1',
      mode: 'persistent',
      controllerKey: 1000,
      serverId: '500478d2-0c9b-3652-a378-b7703858a3c8',
      datastore: 'LX_ESX_SVC_DC1_21',
      id: '6000C293-d882-595d-670c-836daa2a2aa4',
      filename: '[LX_ESX_SVC_DC1_21] alton-buttner.example.com/alton-buttner.example.com.vmdk',
      size: 13631488,
      key: 2000,
      unitNumber: 0,
      sizeGb: 13
    },
    {
      thin: false,
      name: 'Hard disk 2',
      mode: 'persistent',
      controllerKey: 1001,
      serverId: '500478d2-0c9b-3652-a378-b7703858a3c8',
      datastore: 'LX_ESX_SVC_DC1_21',
      id: '6000C292-ca02-a2e7-c868-fe8f86d66ae8',
      filename: '[LX_ESX_SVC_DC1_21] alton-buttner.example.com/alton-buttner.example.com_1.vmdk',
      size: 11534336,
      key: 2016,
      unitNumber: 0,
      sizeGb: 11
    },
    {
      thin: false,
      name: 'Hard disk 3',
      mode: 'persistent',
      controllerKey: 1001,
      serverId: '500478d2-0c9b-3652-a378-b7703858a3c8',
      datastore: 'LX_ESX_SVC_DC1_21',
      id: '6000C294-4706-a370-4f30-8022353519ba',
      filename: '[LX_ESX_SVC_DC1_21] alton-buttner.example.com/alton-buttner.example.com_2.vmdk',
      size: 1048576,
      key: 2017,
      unitNumber: 1,
      sizeGb: 1
    }
  ],
  controllers: [
    {
      type: 'VirtualLsiLogicController',
      key: 1000
    },
    {
      type: 'VirtualLsiLogicController',
      key: 1001
    }
  ]
};

export const emptyState = {
  config: {
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual'
    },
    diskModeTypes: {
      persistent: 'Persistent',
      independent_persistent: 'Independent - Persistent',
      independent_nonpersistent: 'Independent - Nonpersistent'
    },
    storagePods: {},
    datastores: {}
  },
  volumes: [],
  controllers: []
};