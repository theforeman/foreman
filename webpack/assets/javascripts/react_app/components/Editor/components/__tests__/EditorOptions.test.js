import React from 'react';
import { mount } from '@theforeman/test';

import EditorOptions from '../EditorOptions';
import { editorOptions, showBooleans, inputEditorContextValue, diffEditorContextValue } from '../../Editor.fixtures';
import { EditorContext } from '../../EditorContext';

const props = { ...editorOptions, ...showBooleans, isDiff: true };

describe('EditorOptions', () => {
  it('simulate onClick', () => {
    const toggleMaskValue = jest.fn();
    const revertChanges = jest.fn();
    jest.mock('../EditorOptions');
    window.confirm = jest.fn(() => true);

    const diffWrapper = mount(
      <EditorContext.Provider value={diffEditorContextValue}>
        <EditorOptions
          {...props}
          toggleMaskValue={toggleMaskValue}
          revertChanges={revertChanges}
          isDiff
        />
      </EditorContext.Provider>
    );

    const inputWrapper = mount(
      <EditorContext.Provider value={inputEditorContextValue}>
        <EditorOptions
          {...props}
          toggleMaskValue={toggleMaskValue}
          revertChanges={revertChanges}
          isDiff
        />
      </EditorContext.Provider>
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
    expect(revertChanges).toHaveBeenCalledTimes(1);
    expect(diffEditorContextValue.setSelectedView).toHaveBeenCalledTimes(1);
    expect(diffEditorContextValue.setSelectedView).toHaveBeenCalledWith("input");
    expect(window.confirm).toHaveBeenCalledTimes(1);
  });
});
