import React from 'react';
import { act, fireEvent, render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { flushPatternflyTimers } from '../../common/rtlTestHelpers';
import { LegacyUIKebab } from './LegacyUIKebab';

describe('LegacyUIKebab', () => {
  it('opens a menu with a link to the legacy hosts page', async () => {
    render(<LegacyUIKebab />);
    const toggle = screen.getByRole('button', {
      name: 'legacy-ui-kebab-toggle',
    });
    expect(toggle).toHaveAttribute('aria-expanded', 'false');

    await act(async () => {
      fireEvent.click(toggle);
    });
    await flushPatternflyTimers();

    expect(toggle).toHaveAttribute('aria-expanded', 'true');
    expect(screen.getByRole('menuitem', { name: 'Legacy UI' })).toHaveAttribute(
      'href',
      '/hosts'
    );
  });
});
