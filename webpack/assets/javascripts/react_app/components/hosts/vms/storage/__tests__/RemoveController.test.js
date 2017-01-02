jest.dontMock('../StorageContainer');

import React from 'react';
import { mount } from 'enzyme';
import StorageContainer from '../StorageContainer';

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

describe('Remove Controller default', () => {
  beforeEach(() => {
    global.__ = (text) => text;
  });

  it('removes a controller', () => {
    const wrapper = setup();

    wrapper.find('#add-controller').simulate('click');
    wrapper.find('#add-controller').simulate('click');
    wrapper.find('.remove').at(1).simulate('click');
    // We had 3 controllers 1000, 1001, 1002. We clicked on the middle one with key 1001.
    expect(wrapper.state().controllers.map((item) => {return item.SCSIKey; }))
    .toEqual([1000, 1002]);
    expect(wrapper.state().controllers.length).toBe(2);
    wrapper.unmount();
  });
});
