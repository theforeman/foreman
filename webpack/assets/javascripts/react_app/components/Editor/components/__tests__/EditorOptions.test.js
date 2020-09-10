import React from 'react';
import { mount } from '@theforeman/test';
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import EditorOptions from '../EditorOptions';
import { editorOptions, showBooleans } from '../../Editor.fixtures';

const props = { ...editorOptions, ...showBooleans, isDiff: true };

const fixtures = {
  'renders EditorOptions': props,
};

describe('EditorOptions', () => {
  describe('EditorOptions', () =>
    testComponentSnapshotsWithFixtures(EditorOptions, fixtures));

  describe('simulate onClick', () => {
    const toggleMaskValue = jest.fn();
    const changeTab = jest.fn();
    const revertChanges = jest.fn();
    jest.mock('../EditorOptions');
    window.confirm = jest.fn(() => true);

    const diffWrapper = mount(
      <EditorOptions
        {...props}
        changeTab={changeTab}
        toggleMaskValue={toggleMaskValue}
        revertChanges={revertChanges}
        isDiff
        selectedView="diff"
      />
    );

    const inputWrapper = mount(
      <EditorOptions
        {...props}
        changeTab={changeTab}
        toggleMaskValue={toggleMaskValue}
        revertChanges={revertChanges}
        isDiff
      />
    );

    diffWrapper
      .find('#undo-btn')
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
    expect(window.confirm).toHaveBeenCalledTimes(1);
  });
});
