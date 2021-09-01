import React from 'react';
import { Provider } from 'react-redux';
import { mount } from '@theforeman/test';
import { Button } from '@patternfly/react-core';
import store from '../../redux';
import ConfirmModal, { openConfirmModal } from './index';

describe('Confirm modal', () => {
  it('should flow', async () => {
    const btnText = 'Trigger confirm!';
    const modalMessage = 'Are you sure?';
    const modalTitle = 'Hello there';
    const onConfirm = jest.fn();
    const handleConfirmClick = () => {
      store.dispatch(
        openConfirmModal({title: modalTitle, message: modalMessage, onConfirm })
      )
    };

    const wrapper = mount(
      <Provider store={store}>
        <ConfirmModal />
        <Button id="btn-confirm-trigger" onClick={handleConfirmClick}>{btnText}</Button>
      </Provider>
    );
    
    wrapper
        .find('#btn-confirm-trigger')
        .first()
        .simulate('click');
    
    expect(wrapper.find('.pf-c-modal-box__body').text()).toEqual(modalMessage);
    expect(wrapper.find('.pf-c-modal-box__title-text').text()).toEqual(modalTitle);

    expect(onConfirm).toBeCalledTimes(0);

    wrapper
        .find('.pf-c-modal-box__footer > Button')
        .first()
        .simulate('click');
    
    expect(onConfirm).toBeCalledTimes(1);

    // The modal should be hidden
    expect(wrapper.find('.pf-c-modal-box__body')).toHaveLength(0);
  });
});
