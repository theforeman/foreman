import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Link from './index';

describe('documentation links', () => {
  it('should have an external link to documentation', () => {
    render(<Link href="http://theforeman.org" />);

    expect(
      screen.getByRole('menuitem', { name: /Documentation/i })
    ).toBeInTheDocument();
  });
});
