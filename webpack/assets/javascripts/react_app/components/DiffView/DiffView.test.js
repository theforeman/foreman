import React from 'react';
import { fixtures } from './Diff.fixtures';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import DiffView from './DiffView';

describe('DiffView', () => {
  describe('rendering', () => {
    it('render DiffView w/oldText & newText', () => {
      render(<DiffView {...fixtures.diffMock} />)
      const table = screen.getByRole('table')

      expect(table).toHaveClass("diff-split")
      expect(screen.getByText('hello there friend')).toBeInTheDocument()
    })

    it('render DiffView w/Patch', () => {
      render(<DiffView {...fixtures.patchMock} />)
      const table = screen.getByRole('table')

      expect(table).toHaveClass("diff-unified")
      expect(screen.getByText('fooo')).toBeInTheDocument()
    })
  })
});
