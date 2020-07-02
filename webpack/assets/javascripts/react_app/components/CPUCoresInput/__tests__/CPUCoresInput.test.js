import React from 'react';
import { mount } from '@theforeman/test';
import { Provider } from 'react-redux';
import CPUCoresInput from '../';
import Store from "../../../redux";


describe('CPUCoresInput', () => {
  it('warning alert', async () => {
    const component = mount(
        <Provider store={Store}>
          <CPUCoresInput defaultValue={11} recommendedMaxValue={10} inputKey={'cpus'} />
        </Provider>
    );
    expect(component.find('input').prop('value')).toEqual('11');
    expect(component.find('.warning-icon').exists()).toBeTruthy();
  });

  it('error alert', async () => {
    const component = mount(
        <Provider store={Store}>
          <CPUCoresInput defaultValue={21} maxValue={20} inputKey={'cpus'}/>
        </Provider>
    );
    expect(component.find('input').prop('value')).toEqual('21');
    expect(component.find('.error-icon').exists()).toBeTruthy();
  });
});
