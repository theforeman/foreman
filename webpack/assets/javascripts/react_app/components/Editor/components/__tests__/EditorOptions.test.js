import React from 'react';
import { Provider } from 'react-redux';
import { mount } from '@theforeman/test';

import EditorOptions from '../EditorOptions';
import { editorOptions, showBooleans } from '../../Editor.fixtures';
import store from '../../../../redux';
import ConfirmModal from '../../../ConfirmModal';

const props = { ...editorOptions, ...showBooleans, isDiff: true };

describe('EditorOptions', () => {
  it('simulate onClick', async () => {
    const toggleMaskValue = jest.fn();
    const changeTab = jest.fn();
    const revertChanges = jest.fn();
    jest.mock('../EditorOptions');

    const diffWrapper = mount(
      <Provider store={store}>
        <EditorOptions
          {...props}
          changeTab={changeTab}
          toggleMaskValue={toggleMaskValue}
          revertChanges={revertChanges}
          isDiff
          selectedView="diff"
        />
        <ConfirmModal />
      </Provider>
    );

    const inputWrapper = mount(
      <Provider store={store}>
        <EditorOptions
          {...props}
          changeTab={changeTab}
          toggleMaskValue={toggleMaskValue}
          revertChanges={revertChanges}
          isDiff
        />
      </Provider>
    );

    diffWrapper
      .find('#undo-btn')
      .at(0)
      .simulate('click');

    expect(diffWrapper.text().includes('Revert Local Changes')).toBe(true);
    diffWrapper
      .find('button.pf-c-button.pf-m-danger')
      .at(0)
      .simulate('click');

    inputWrapper
      .find('#hide-btn')
      .at(0)
      .simulate('click');
    diffWrapper
      .find('#import-btn')
      .at(0)
      .simulate('click');

    expect(toggleMaskValue).toHaveBeenCalledTimes(1);
    expect(changeTab).toHaveBeenCalledTimes(1);
    expect(revertChanges).toHaveBeenCalledTimes(1);
  });
});
