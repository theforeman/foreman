import React from 'react';
import { mount } from 'enzyme';
import { act } from 'react-dom/test-utils';

import OrderableDataList from '../OrderableDataList';

const bootDeviceOptions = [
  { label: 'Harddisk', value: 'disk' },
  { label: 'Network', value: 'network' },
  { label: 'CD-ROM', value: 'cdrom' },
];

describe('OrderableDataList', () => {
  it('always renders the boot order DataList', () => {
    const wrapper = mount(
      <OrderableDataList
        id="boot-order"
        options={bootDeviceOptions}
        defaultValue={[]}
      />
    );

    expect(wrapper.find('DataList')).toHaveLength(1);
    expect(wrapper.text()).toContain('No boot devices selected');
  });

  it('renders hidden inputs in boot order when name is provided', () => {
    const wrapper = mount(
      <OrderableDataList
        id="boot-order"
        name="host[compute_attributes][boot_order][]"
        options={bootDeviceOptions}
        defaultValue={['network', 'disk']}
      />
    );

    const inputs = wrapper.find('input[type="hidden"]');
    expect(inputs).toHaveLength(2);
    expect(inputs.at(0).prop('value')).toBe('network');
    expect(inputs.at(1).prop('value')).toBe('disk');
  });

  it('removes a boot device from the list', () => {
    const onChange = jest.fn();
    const wrapper = mount(
      <OrderableDataList
        id="boot-order"
        options={bootDeviceOptions}
        defaultValue={['network', 'disk']}
        onChange={onChange}
      />
    );

    act(() => {
      wrapper.find('#boot-order-remove-network Button').simulate('click');
    });
    wrapper.update();

    expect(onChange).toHaveBeenLastCalledWith(['disk']);
  });
});
