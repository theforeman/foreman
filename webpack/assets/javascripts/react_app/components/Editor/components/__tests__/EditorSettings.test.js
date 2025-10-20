
import React from 'react'
import { act, configure, fireEvent, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect';

import { noop } from '../../../../common/helpers';

import EditorSettings from '../EditorSettings';
import { dropdowns } from '../../Editor.fixtures';

const fixtures = {
  default: {
    ...dropdowns,
    mode: 'Ruby',
    selectedView: 'input',
    theme: 'Github',
    autocompletion: true,
    liveAutocompletion: false,
    keyBinding: 'vim',
    changeSetting: noop,
  },
  withPreview: {
    ...dropdowns,
    mode: 'Ruby',
    selectedView: 'preview',
    theme: 'Github',
    autocompletion: true,
    liveAutocompletion: false,
    keyBinding: 'vim',
    changeSetting: noop,
  },
};

configure({ testIdAttribute: 'data-ouia-component-id' })

describe('EditorSettings', () => {
  it('renders with default', async () => {
    render(<EditorSettings {...fixtures.default} />);
    const settingsButton = screen.getByTestId('editor-settings-button')

    await act(async () => await fireEvent.click(settingsButton) )

    expect(screen.getByLabelText("Syntax")).toBeInTheDocument();
    expect(screen.getByLabelText("Keybind")).toBeInTheDocument();
    expect(screen.getByLabelText("Theme")).toBeInTheDocument();
    expect(screen.getByLabelText("Autocompletion")).toBeInTheDocument();
    expect(screen.getByLabelText("Live Autocompletion")).toBeInTheDocument();
  });
  it('renders with preview', async () => {
    render(<EditorSettings {...fixtures.withPreview} />);
    const settingsButton = screen.getByTestId('editor-settings-button')

    await act(async () => await fireEvent.click(settingsButton) )

    expect(screen.getByLabelText("Syntax")).toBeInTheDocument();
    expect(screen.getByLabelText("Keybind")).toBeInTheDocument();
    expect(screen.getByLabelText("Theme")).toBeInTheDocument();
    expect(screen.getByLabelText("Autocompletion")).toBeInTheDocument();
    expect(screen.getByLabelText("Live Autocompletion")).toBeInTheDocument();

    /* preview view */
    const modeSelect = screen.getByLabelText("Syntax");
    const keybindingSelect = screen.getByLabelText("Keybind");

    expect(modeSelect).toBeDisabled();
    expect(keybindingSelect).toBeDisabled();

    const themeSelect = screen.getByLabelText("Theme");
    expect(themeSelect).not.toBeDisabled();

    const autocompletionCheckbox = screen.getByLabelText("Autocompletion");
    const liveAutocompletionCheckbox = screen.getByLabelText("Live Autocompletion");

    expect(autocompletionCheckbox).not.toBeDisabled();
    expect(liveAutocompletionCheckbox).not.toBeDisabled();
  })
  describe('form interactions', () => {
    it('should call changeSetting when mode is changed', async () => {
      const mockChangeSetting = jest.fn();
      render(<EditorSettings {...fixtures.default} changeSetting={mockChangeSetting} />);

      const settingsButton = screen.getByTestId('editor-settings-button')
      await act(async () => await fireEvent.click(settingsButton) )

      const modeSelect = screen.getByLabelText(/syntax/i);
      await userEvent.selectOptions(modeSelect, 'Text');

      expect(mockChangeSetting).toHaveBeenCalledWith({ mode: 'Text' });
    });
  })
})
