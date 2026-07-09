import React from 'react';
import { act, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import { rtlHelpers } from '../../../../common/rtlTestHelpers';
import EditorSettings from '../EditorSettings';
import { dropdowns } from '../../Editor.fixtures';

const { renderWithI18n } = rtlHelpers;

const defaultProps = {
  ...dropdowns,
  mode: 'Ruby',
  selectedView: 'input',
  theme: 'Github',
  autocompletion: true,
  liveAutocompletion: false,
  keyBinding: 'vim',
  changeSetting: jest.fn(),
};

const renderEditorSettings = (props = {}) => {
  const changeSetting = props.changeSetting ?? jest.fn();

  renderWithI18n(
    <EditorSettings {...defaultProps} {...props} changeSetting={changeSetting} />
  );

  return { changeSetting };
};

const getSettingsButton = () =>
  screen.getByRole('button', { name: 'Settings' });

const openSettingsPopover = async () => {
  await screen.findByRole('button', { name: 'Settings' });

  await act(async () => {
    userEvent.click(getSettingsButton());
    await new Promise(resolve => setTimeout(resolve, 0));
  });

  await screen.findByText('Syntax');
};

const selectDropdownOption = async (currentValue, optionName) => {
  await act(async () => {
    userEvent.click(screen.getByRole('button', { name: currentValue }));
    await new Promise(resolve => setTimeout(resolve, 0));
  });

  await act(async () => {
    userEvent.click(screen.getByRole('option', { name: optionName }));
    await new Promise(resolve => setTimeout(resolve, 0));
  });
};

describe('EditorSettings', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders the settings button', async () => {
    renderEditorSettings();

    expect(
      await screen.findByRole('button', { name: 'Settings' })
    ).toBeInTheDocument();
  });

  it('shows editor settings in the popover', async () => {
    renderEditorSettings();

    await openSettingsPopover();

    expect(
      screen.getByRole('heading', { name: 'Settings' })
    ).toBeInTheDocument();
    expect(screen.getByText('Syntax')).toBeInTheDocument();
    expect(screen.getByText('Keybind')).toBeInTheDocument();
    expect(screen.getByText('Theme')).toBeInTheDocument();
    expect(screen.getByText('Autocompletion')).toBeInTheDocument();
    expect(screen.getByText('Live Autocompletion')).toBeInTheDocument();
    expect(screen.getByText('Ruby')).toBeInTheDocument();
    expect(screen.getByText('vim')).toBeInTheDocument();
    expect(screen.getByText('Github')).toBeInTheDocument();
  });

  it('calls changeSetting when syntax is changed', async () => {
    const { changeSetting } = renderEditorSettings();

    await openSettingsPopover();

    await selectDropdownOption('Ruby', 'Json');

    expect(changeSetting).toHaveBeenCalledWith({ mode: 'Json' });
  });

  it('calls changeSetting when key binding is changed', async () => {
    const { changeSetting } = renderEditorSettings();

    await openSettingsPopover();

    await selectDropdownOption('vim', 'Emacs');

    expect(changeSetting).toHaveBeenCalledWith({ keyBinding: 'Emacs' });
  });

  it('calls changeSetting when theme is changed', async () => {
    const { changeSetting } = renderEditorSettings();

    await openSettingsPopover();

    await selectDropdownOption('Github', 'Monokai');

    expect(changeSetting).toHaveBeenCalledWith({ theme: 'Monokai' });
  });

  it('calls changeSetting when autocompletion is toggled', async () => {
    const { changeSetting } = renderEditorSettings();

    await openSettingsPopover();

    userEvent.click(screen.getByRole('checkbox', { name: 'Autocompletion' }));

    expect(changeSetting).toHaveBeenCalledWith({ autocompletion: false });
  });

  it('calls changeSetting when live autocompletion is toggled', async () => {
    const { changeSetting } = renderEditorSettings();

    await openSettingsPopover();

    userEvent.click(
      screen.getByRole('checkbox', { name: 'Live Autocompletion' })
    );

    expect(changeSetting).toHaveBeenCalledWith({ liveAutocompletion: true });
  });

  it('disables live autocompletion when autocompletion is off', async () => {
    renderEditorSettings({ autocompletion: false });

    await openSettingsPopover();

    expect(
      screen.getByRole('checkbox', { name: 'Live Autocompletion' })
    ).toBeDisabled();
  });

  describe('preview view', () => {
    it('disables syntax and keybind selects but keeps theme enabled', async () => {
      renderEditorSettings({ selectedView: 'preview' });

      await openSettingsPopover();

      expect(screen.getByRole('button', { name: 'Ruby' })).toBeDisabled();
      expect(screen.getByRole('button', { name: 'vim' })).toBeDisabled();
      expect(screen.getByRole('button', { name: 'Github' })).toBeEnabled();
    });
  });
});
