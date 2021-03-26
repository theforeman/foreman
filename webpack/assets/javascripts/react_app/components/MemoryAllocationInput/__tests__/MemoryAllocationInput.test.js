import React from 'react';
import { mount } from '@theforeman/test';
import { Provider } from 'react-redux';
import { MEGABYTES } from '../constants';
import MemoryAllocationInput from '../';


describe('MemoryAllocationInput', () => {

  it('warning alert', async () => {
      const setWarning = jest.fn();
      const component = mount(
        <MemoryAllocationInput
          value={11264*MEGABYTES}
          recommendedMaxValue={10240}
          setWarning={setWarning}
        />
      );
      expect(component.find('.foreman-numeric-input-input').prop('value')).toEqual('11264 MB');
      expect(setWarning.mock.calls.length).toBe(1);
  });

  it('error alert', async () => {
      const setError = jest.fn();
      const component = mount(
        <MemoryAllocationInput value={21504*MEGABYTES} maxValue={20480*MEGABYTES} setError={setError} />
      );
      expect(component.find('.foreman-numeric-input-input').prop('value')).toEqual('21504 MB');
      expect(setError.mock.calls.length).toBe(1);
  });
});
