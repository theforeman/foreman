import React from 'react';
import { mount } from '@theforeman/test';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import MemoryAllocationInput from '../MemoryAllocationInput';

const props = {
  label: 'Memory',
};

const fixtures = {
  'should render with default props': props,
};

describe('MemoryAllocationInput', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(MemoryAllocationInput, fixtures);
  });

  it('MB to GB change', async () => {
    const component = mount(<MemoryAllocationInput defaultValue={768} />);
    expect(component.find('input').prop('value')).toEqual('768 MB');
    component
      .find('.foreman-numeric-input-handler-up')
      .at(0)
      .simulate('mousedown');

    component.update();
    expect(component.find('input').prop('value')).toEqual('1 GB');
  });
});

it('warning alert', async () => {
  const component = mount(
    <MemoryAllocationInput defaultValue={11264} recommendedMaxValue={10240} />
  );
  expect(component.find('input').prop('value')).toEqual('11 GB');
  expect(component.find('.warning-icon').exists()).toBeTruthy();
});

it('error alert', async () => {
  const component = mount(
    <MemoryAllocationInput defaultValue={21504} maxValue={20480} />
  );
  expect(component.find('input').prop('value')).toEqual('21 GB');
  expect(component.find('.error-icon').exists()).toBeTruthy();
});
