import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';

import EditorSettings from '../EditorSettings';
import {
  inputEditorContextValue,
  previewEditorContextValue,
} from '../../Editor.fixtures';
import { EditorContext } from '../../EditorContext';
import { editorSettingsFixtures } from '../../Editor.fixtures';

describe('EditorSettings', () => {
  it('should render all elements in preview view', async () => {
    const {
      getByTestId,
      getByLabelText,
      getByText,
      getAllByText,
    } = await render(
      <EditorContext.Provider value={previewEditorContextValue}>
        <EditorSettings {...editorSettingsFixtures} />
      </EditorContext.Provider>
    );

    // open settings
    const openSettingsButton = getByLabelText('Editor settings open button');
    fireEvent.click(openSettingsButton);

    // wait for the DropDown menu of the settings to open:
    await waitFor(() => getByText(/Settings/i));

    // Titles
    getByText(/Settings/i);
    getByText(/Syntax/i);
    getByText(/Keybind/i);
    getByText(/Theme/i);
    expect(getAllByText(/Autocompletion/i)).toHaveLength(2); // 1. Autocompletion, 2. Live Autocompletion
    getByText(/Live Autocompletion/i);

    // DropDowns
    expect(getByLabelText(/Keybindings Dropdown/i)).not.toBeDisabled();
    expect(getByTestId('syntax-dropdown-menu')).not.toBeDisabled();
    expect(getByLabelText(/Themes Dropdown/i)).not.toBeDisabled();

    // autocompletion
    expect(getByLabelText(/autocompletion input/i)).toBeInTheDocument();
  });

  /**********************************************************/

  it('should flow: functionality check', async () => {
    const changeSetting = jest.fn();

    const {
      getByLabelText,
      getByText,
      getAllByLabelText,
      getByTestId,
    } = await render(
      <EditorContext.Provider value={inputEditorContextValue}>
        <EditorSettings
          {...editorSettingsFixtures}
          changeSetting={changeSetting}
        />
      </EditorContext.Provider>
    );

    // open settings
    const openSettingsButton = getByLabelText('Editor settings open button');
    fireEvent.click(openSettingsButton);

    // wait for the DropDown menu of the settings to open:
    await waitFor(() => getByText(/Settings/i));

    // Themes Dropdown Functionality:

    // Click on the Themes Dropdown Menu
    fireEvent.click(getByLabelText(/Themes dropdown/i));

    // ensure the dropdown menu contains the expected items:
    const themesDropdownItem = getAllByLabelText('Theme dropdown item');
    expect(themesDropdownItem).toHaveLength(2);
    expect(themesDropdownItem[0]).toHaveTextContent('Github');
    expect(themesDropdownItem[1]).toHaveTextContent('Monokai');

    // Click on the Monokai theme
    fireEvent.click(themesDropdownItem[1]);

    // expect the changeSetting to have been called with the expected value:
    expect(changeSetting).lastCalledWith({ theme: 'Monokai' });

    // Keybindings Dropdown Functionality:

    // Click on the Keybindings Dropdown Menu
    fireEvent.click(getByLabelText(/Keybindings dropdown/i));

    // ensure the dropdown menu contains the expected items:
    const keybindingsDropdownItem = getAllByLabelText(
      'Keybinding dropdown item'
    );
    expect(keybindingsDropdownItem).toHaveLength(3);
    expect(keybindingsDropdownItem[0]).toHaveTextContent('Default');
    expect(keybindingsDropdownItem[1]).toHaveTextContent('Emacs');
    expect(keybindingsDropdownItem[2]).toHaveTextContent('Vim');

    // Click on the Vim keybinding
    fireEvent.click(keybindingsDropdownItem[2]);

    // expect the changeSetting to have been called with the expected value:
    expect(changeSetting).lastCalledWith({ keyBinding: 'Vim' });

    // Syntax Dropdown Functionality:

    // Click on the Syntax Dropdown Menu:
    fireEvent.click(getByTestId('syntax-dropdown-menu'));

    // wait for the DropDown menu of modes to open:
    waitFor(() => getByLabelText(/Mode Dropdown/i));

    // ensure the dropdown menu contains the expected items:
    const modeDropdownItem = getAllByLabelText('Syntax dropdown item');
    expect(modeDropdownItem).toHaveLength(7);
    expect(modeDropdownItem[0]).toHaveTextContent('Text');
    expect(modeDropdownItem[1]).toHaveTextContent('Json');
    expect(modeDropdownItem[2]).toHaveTextContent('Ruby');
    expect(modeDropdownItem[3]).toHaveTextContent('Html_ruby');
    expect(modeDropdownItem[4]).toHaveTextContent('Sh');
    expect(modeDropdownItem[5]).toHaveTextContent('Xml');
    expect(modeDropdownItem[6]).toHaveTextContent('Yaml');

    // Click on the Ruby mode
    fireEvent.click(modeDropdownItem[2]);

    // expect the changeSetting to have been called with the expected value:
    expect(changeSetting).lastCalledWith({ mode: 'Ruby' });

    // Click on the Autocompletion checkbox:

    fireEvent.click(getByLabelText(/autocompletion input/i));

    // expect the changeSetting to have been called with the expected value:
    expect(changeSetting).lastCalledWith({ autocompletion: false });

    // Click on the Live Autocompletion checkbox:

    fireEvent.click(getByLabelText(/autocompletion live input/i));

    // expect the changeSetting to have been called with the expected value:
    expect(changeSetting).lastCalledWith({ liveAutocompletion: true });

    expect(changeSetting).toHaveBeenCalledTimes(5);
  });
});
