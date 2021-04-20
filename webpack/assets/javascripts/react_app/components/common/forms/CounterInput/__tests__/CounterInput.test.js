import React from 'react';
import { mount } from '@theforeman/test';
import CounterInput from '../';


describe('CounterInput', async () => {
  it('warning alert', () => {
    const setWarning = jest.fn();
    const component = mount(
      <CounterInput value={11} recommendedMaxValue={10} inputKey={'cpus'} setWarning={setWarning} />
    );
    expect(component.find('input').prop('value')).toEqual('11');
    expect(setWarning.mock.calls.length).toBe(1);
  });

  it('error alert', async () => {
    const setError = jest.fn();
    const component = mount(
      <CounterInput value={21} max={20} inputKey={'cpus'} setError={setError} />
    );
    expect(component.find('input').prop('value')).toEqual('21');
    expect(setError.mock.calls.length).toBe(1);
  });
});
