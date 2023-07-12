import React from 'react';
import { render, fireEvent } from '@testing-library/react';
                     import '@testing-library/jest-dom';

import EditorToolbar from '../EditorToolbar';
import { EditorContext } from '../../EditorContext';
import {
  editorOptions,
  showBooleans,
  inputEditorContextValue,
  previewEditorContextValue,
  editorTabsWithoutDiff,
  editorTabsWithDiff,
  PF_CURRENT,
} from '../../Editor.fixtures';

const { data: editorOptionsData, ...restEditorOptions } = editorOptions;

const props = {
  ...editorOptionsData,
  ...restEditorOptions,
  ...showBooleans,
};

describe('EditorToolbar', () => {

  it('Renders all subcomponents', async () => {
    const { getByText, getByRole, getByLabelText, unmount } = await render(
      <EditorContext.Provider value={previewEditorContextValue}>
        <EditorToolbar
          {...props}
          isDiff={true}
          isRendering
          isSelectOpen={true}
          isLoading={true}
        />
      </EditorContext.Provider>
    );

    // Spinner
    expect(getByRole('progressbar')).toBeInTheDocument();

    // Tabs
    expect(getByRole('tablist')).toBeInTheDocument();

    // HostSelect
    expect(getByLabelText('Host selection menu option')).toBeInTheDocument();
    expect(getByText(/filter host.../i)).toBeInTheDocument();

    // SafemodeCheckbox
    expect(getByText(/safemode/i)).toBeInTheDocument();

    // Alert
    expect(getByText(/Preview is outdated./i)).toBeInTheDocument();

    // Options
    expect(getByRole('option')).toBeInTheDocument();

    unmount();
  });

  /**********************************************************/

  it('EditorTabs Functionality: Without Diff', async () => {
    const { getByText, unmount } = await render(
      <EditorContext.Provider value={inputEditorContextValue}>
        <EditorToolbar
          {...props}
          isRendering
          isLoading={false}
          {...editorTabsWithoutDiff}
        />
    </EditorContext.Provider>
    );

    // ensuring the tab buttons are in the document:
    const editorButton = await getByText(/editor/i);
    const changesButton = await getByText(/changes/i);
    const previewButton = await getByText(/preview/i);

    // We need to get the container of the buttons, because only they have the attribute PF_CURRENT or disabled
    const editorButtonContainer = editorButton.parentElement.parentElement;
    const changesButtonContainer = changesButton.parentElement.parentElement;
    const changesButtonContainer2 = changesButton.parentElement;
    const previewButtonContainer = previewButton.parentElement.parentElement;

    // Check that only the selected button looks selected
    expect(editorButtonContainer.classList.contains(PF_CURRENT)).toBe(true);
    expect(changesButtonContainer.classList.contains(PF_CURRENT)).toBe(false);
    expect(previewButtonContainer.classList.contains(PF_CURRENT)).toBe(false);

    // Without Diff, the changes button should be disabled
    expect(changesButtonContainer2).toBeDisabled;

    // Button Clicks:

    // click button: Preview, ensure the change view function was called with the correct value
    fireEvent.click(previewButton);
    expect(inputEditorContextValue.setSelectedView).toHaveBeenLastCalledWith("preview");

    // click button: Editor, Because we do not change selectedView, when we press on this button we should not see changes
    fireEvent.click(editorButton);
    expect(inputEditorContextValue.setSelectedView).toHaveBeenLastCalledWith("preview");
    expect(inputEditorContextValue.setSelectedView).not.toHaveBeenLastCalledWith("editor");

    expect(editorButtonContainer.classList.contains(PF_CURRENT)).toBe(true);
    expect(previewButtonContainer.classList.contains(PF_CURRENT)).toBe(false);

    expect(inputEditorContextValue.setSelectedView).toHaveBeenCalledTimes(1);

    unmount();
  });

  /**********************************************************/

  it('EditorTabs Functionality: With Diff', async () => {
    // Rerender component with diff to check the functionality of changes

    const { getByText, unmount } = await render(
      <EditorContext.Provider value={inputEditorContextValue}>
        <EditorToolbar
        {...props}
        isRendering
        isLoading={false}
        {...editorTabsWithDiff}
        />
    </EditorContext.Provider>
    );

    // ensure the tab buttons are in the document:
    const editorButton = await getByText(/editor/i);
    const changesButton = await getByText(/changes/i);
    const previewButton = await getByText(/preview/i);

    // only the container of changes button have the attribute disabled
    const changesButtonContainer = changesButton.parentElement;

    // With Diff, the changes button should not be disabled
    expect(changesButtonContainer).not.toBeDisabled();

    // click button: Changes, ensure the change view function was called with the correct value
    fireEvent.click(changesButton);
    expect(inputEditorContextValue.setSelectedView).toHaveBeenLastCalledWith("diff");

    fireEvent.click(previewButton);
    expect(inputEditorContextValue.setSelectedView).toHaveBeenLastCalledWith("preview");

    fireEvent.click(editorButton);
    expect(inputEditorContextValue.setSelectedView).toHaveBeenLastCalledWith("preview");
    // because the selectedView is already input, the function shouldn't be called again
    expect(inputEditorContextValue.setSelectedView).not.toHaveBeenLastCalledWith("editor");

    expect(inputEditorContextValue.setSelectedView).toHaveBeenCalledTimes(3);

    unmount();
  });
});
