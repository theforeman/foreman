import React from 'react';
import { screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import userEvent from '@testing-library/user-event';
import API from '../../../redux/API/API';
import { rtlHelpers } from '../../../common/rtlTestHelpers';
import { editorOptions } from '../Editor.fixtures';
import Editor from '../index';

jest.mock('@patternfly/react-core', () => {
  const actual = jest.requireActual('@patternfly/react-core');
  return {
    ...actual,
    Tooltip: ({ children }) => children,
  };
});

const { renderWithStore } = rtlHelpers;

describe('Editor integration test', () => {
  beforeEach(() => {
    API.get.mockResolvedValue({ data: [] });
    API.post.mockResolvedValue({ data: ['rendered content'] });
  });

  it('should switch to preview tab and open fullscreen modal', async () => {
    renderWithStore(<Editor {...editorOptions} />);

    expect(
      screen.getByRole('tab', { name: 'Editor' })
    ).toHaveAttribute('aria-selected', 'true');

    await userEvent.click(screen.getByRole('tab', { name: 'Preview' }));

    expect(
      screen.getByRole('tab', { name: 'Preview' })
    ).toHaveAttribute('aria-selected', 'true');

    await userEvent.click(screen.getByRole('button', { name: 'Maximize' }));

    expect(screen.getByRole('dialog')).toBeInTheDocument();
  });
});
