import React from 'react';
import { render, screen, fireEvent, configure } from '@testing-library/react';
import '@testing-library/jest-dom';

import EditorSettings from '../EditorSettings';
import { dropdowns } from '../../Editor.fixtures';

jest.mock('@patternfly/react-core', () => {
  const actual = jest.requireActual('@patternfly/react-core');

  function Popover({ bodyContent, children }) {
    return (
      <>
        {children}
        <div data-ouia-component-id="editor-settings-popover-body">
          {bodyContent}
        </div>
      </>
    );
  }

  return { ...actual, Popover };
});

configure({ testIdAttribute: 'data-ouia-component-id' });

const baseProps = {
  ...dropdowns,
  mode: 'Ruby',
  selectedView: 'input',
  theme: 'Github',
  autocompletion: true,
  liveAutocompletion: false,
  keyBinding: 'Vim',
  changeSetting: jest.fn(),
};

describe('EditorSettings', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders the settings button', () => {
    render(<EditorSettings {...baseProps} />);

    expect(screen.getByTestId('editor-settings-button')).toBeInTheDocument();
    expect(document.getElementById('cog-btn')).toBeInTheDocument();
  });

  it('renders settings controls in the popover body', () => {
    render(<EditorSettings {...baseProps} />);

    expect(screen.getByTestId('editor-settings-popover-body')).toBeInTheDocument();
    expect(screen.getByTestId('mode-select')).toBeInTheDocument();
    expect(screen.getByTestId('keybindings-select')).toBeInTheDocument();
    expect(screen.getByTestId('themes-select')).toBeInTheDocument();
    expect(screen.getByTestId('autocompletion-checkbox')).toBeInTheDocument();
    expect(screen.getByTestId('live-autocompletion-checkbox')).toBeInTheDocument();
  });

  it('disables syntax and keybind selects on preview tab', () => {
    render(<EditorSettings {...baseProps} selectedView="preview" />);

    expect(screen.getByTestId('mode-select')).toBeDisabled();
    expect(screen.getByTestId('keybindings-select')).toBeDisabled();
    expect(screen.getByTestId('themes-select')).not.toBeDisabled();
  });

  it('calls changeSetting when mode is changed', () => {
    render(<EditorSettings {...baseProps} />);

    fireEvent.change(screen.getByTestId('mode-select'), {
      target: { value: 'Json' },
    });

    expect(baseProps.changeSetting).toHaveBeenCalledWith({ mode: 'Json' });
  });

  it('calls changeSetting when autocompletion is toggled', () => {
    render(<EditorSettings {...baseProps} />);

    fireEvent.click(screen.getByTestId('autocompletion-checkbox'));

    expect(baseProps.changeSetting).toHaveBeenCalledWith({
      autocompletion: false,
    });
  });

  it('disables live autocompletion when autocompletion is off', () => {
    render(<EditorSettings {...baseProps} autocompletion={false} />);

    expect(screen.getByTestId('live-autocompletion-checkbox')).toBeDisabled();
  });
});
