import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import DiffView from './DiffView';
import { diffMock, patchMock } from './Diff.fixtures';

describe('DiffView', () => {
  it('renders diff with oldText and newText in split view', () => {
    render(<DiffView {...diffMock} />);

    expect(screen.getByText('hello friend')).toBeInTheDocument();
    expect(screen.getByText('hello there friend')).toBeInTheDocument();
  });

  it('renders diff from a patch in unified view', () => {
    render(<DiffView {...patchMock} />);

    expect(screen.getByText('fooo')).toBeInTheDocument();
  });
});
