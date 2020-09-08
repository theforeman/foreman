import React from 'react';
import { mount } from '@theforeman/test';
import { Provider } from 'react-redux';
import MemoryAllocationInput from '../';
import Store from "../../../redux";


describe('MemoryAllocationInput', () => {

  it('warning alert', async () => {
      const component = mount(
        <Provider store={Store}>
            <MemoryAllocationInput defaultValue={11264} recommendedMaxValue={10240} />
        </Provider>
      );
      expect(component.find('.foreman-numeric-input-input').prop('value')).toEqual('11264 MB');
      expect(component.find('.warning-icon').exists()).toBeTruthy();
  });

  it('error alert', async () => {
      const component = mount(
        <Provider store={Store}>
            <MemoryAllocationInput defaultValue={21504} maxValue={20480} />
        </Provider>
      );
      expect(component.find('.foreman-numeric-input-input').prop('value')).toEqual('21504 MB');
      expect(component.find('.error-icon').exists()).toBeTruthy();
  });
});
