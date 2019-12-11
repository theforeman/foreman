import { shallow } from '@theforeman/test';
import React from 'react';

import { props } from './disk.fixtures';
import Disk from './';

describe('StorageContainer', () => {
  it('renders controller correctly', () => {
    const wrapper = shallow(<Disk {...props} />);

    expect(wrapper.render().find('.text-vmware-size')).toHaveLength(1);

    expect(wrapper.find('.text-vmware-size').props().value).toEqual(10);
  });

  test.each`
    toChange        | htmlSelector      | toDismiss
    ${'storagePod'} | ${'.storage-pod'} | ${'datastore'}
    ${'datastore'}  | ${'.datastore'}   | ${'storagePod'}
  `(
    'hides $toDismiss on $toChange selection',
    ({ toChange, htmlSelector, toDismiss }) => {
      const updateDisk = jest.fn();
      const wrapper = shallow(<Disk {...props} updateDisk={updateDisk} />);
      const evt = { target: { value: `new_${toChange}_id` } };
      wrapper.find(`Select${htmlSelector}`).simulate('change', evt);
      expect(updateDisk).toHaveBeenCalledWith(toChange, evt);
      expect(updateDisk).toHaveBeenCalledWith(toDismiss, {
        target: { value: null },
      });
    }
  );
});
