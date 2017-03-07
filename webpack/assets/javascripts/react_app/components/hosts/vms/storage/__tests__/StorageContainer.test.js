jest.dontMock('../StorageContainer');

import React from 'react';
import { mount } from 'enzyme';
import StorageContainer from '../StorageContainer';
import { VMStorageVMWare } from '../../../../../constants';

function setup() {
  const vmwareData = {
    'storage_pods': [
      {'StorageCluster': 'StorageCluster (free: 1.15 TB, prov: 7.35 TB, total: 8.5 TB)'}],
    'datastores': [
      {'cfme-esx-55-01-local': 'cfme-esx-55-01-local (free: 614 GB, prov: 348 GB, total: 924 GB)'},
      {'cfme-esx-55-03-local': 'cfme-esx-55-03-local (free: 886 GB, prov: 188 GB, total: 924 GB)'},
      {'cfme-esx-55-04-local': 'cfme-esx-55-04-local (free: 104 GB, prov: 824 GB, total: 924 GB)'},
      {'cfme-esx-55-na01a': 'cfme-esx-55-na01a (free: 548 GB, prov: 8.16 TB, total: 4 TB)'}
    ]
  };

  return mount(<StorageContainer data={vmwareData} />);
}

describe('StorageContainer default', () => {
  beforeEach(() => {
    global.__ = (text) => text;
  });

  it('create default container', () => {
    const wrapper = setup();

    expect(wrapper.find('#storage_volumes legend').text()).toBe('Storage');
    expect(wrapper.state().controllers.length).toBe(1);
    expect(wrapper.state().controllers[0].SCSIKey).toBe(1000);
    expect(wrapper.state().controllers[0].disks.length).toBe(1);
    expect(wrapper.state().controllers[0].disks[0]).toEqual(VMStorageVMWare.defaultDiskAttributes);
  });

  it('adds new controller', () => {
    const wrapper = setup();

    wrapper.find('#add-controller').simulate('click');
    expect(wrapper.state().controllers.length).toBe(2);
  });
});
