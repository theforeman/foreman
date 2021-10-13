import React from 'react';
import { Provider } from 'react-redux';
import { mount } from '@theforeman/test';

import store from '../../../redux';
import ToastsList, { addToast, deleteToast } from '../index'
import { toast } from './fixtures'

describe('ToastsList', () => {
  it('integration', () => {
    const component = mount(
      <Provider store={store}>
        <ToastsList />
      </Provider>);

    let alerts = component.find('.pf-c-alert.foreman-toast');
    expect(alerts.length).toBe(0);

    store.dispatch(addToast(toast));
    component.update();
    alerts = component.find('.pf-c-alert.foreman-toast');
    expect(alerts.length).toBe(1);
    expect(component.find('.pf-c-alert__title').at(0).text()).toBe('Success alert:message');

    store.dispatch(deleteToast(toast.key));
    component.update();
    alerts = component.find('.pf-c-alert.foreman-toast');
    expect(alerts.length).toBe(0);
  });
});
