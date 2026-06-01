import React from 'react';
import { mount } from 'enzyme';
import { Provider } from 'react-redux';
import { BYTES_PER_MB } from '../constants';
import MemoryAllocationInput from '../';


describe('MemoryAllocationInput', () => {

  it('warning alert', async () => {
      const setWarning = jest.fn();
      const component = mount(
        <MemoryAllocationInput
          value={11264*BYTES_PER_MB}
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
        <MemoryAllocationInput value={21504*BYTES_PER_MB} maxValue={20480*BYTES_PER_MB} setError={setError} />
      );
      expect(component.find('.foreman-numeric-input-input').prop('value')).toEqual('21504 MB');
      expect(setError.mock.calls.length).toBe(1);
  });
});
