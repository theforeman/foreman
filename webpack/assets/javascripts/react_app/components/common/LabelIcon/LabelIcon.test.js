import React from 'react';
import '@testing-library/jest-dom';
import { render, screen, act, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import LabelIcon from './index';

describe('LabelIcon', () => {
  it('renders a help icon button that shows popover text on click', async () => {
    render(<LabelIcon text="Yay, label help!" />);
    const button = screen.getByRole('button', { name: 'Help' });
    expect(button).toBeInTheDocument();
    await act(async () => {
      await userEvent.click(button);
    });
    await waitFor(() => {
      expect(screen.getByText('Yay, label help!')).toBeInTheDocument();
    });
  });
});
