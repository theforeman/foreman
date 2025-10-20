import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import { noop } from '../../../../common/helpers';

import EditorHostSelect from '../EditorHostSelect';
import { editorOptions } from '../../Editor.fixtures';

const fixtures = {
  default: {
    show: true,
    open: true,
    selectedItem: { id: '1', name: 'one' },
    onToggle: noop,
    searchQuery: '',
    onSearchChange: noop,
    onSearchClear: noop,
    onChange: noop,
    isLoading: false,
    options: editorOptions.hosts,
  },
  loading: {
    show: true,
    open: true,
    onToggle: noop,
    selectedItem: { id: '1', name: 'one' },
    searchQuery: '',
    onSearchChange: noop,
    onSearchClear: noop,
    onChange: noop,
    isLoading: true,
    options: editorOptions.hosts,
  },
};

describe('EditorHostSelect', () => {
  describe('should render', () => {
    it('renders EditorHostSelect with default props', () => {
      render(<EditorHostSelect {...fixtures.default} />);

      const container = document.querySelector('.pf-c-tabs__item');
      expect(container).toBeInTheDocument();
      expect(container).not.toHaveClass('hidden');

      const selectContainer = document.querySelector('.select-container-pf');
      expect(selectContainer).toBeInTheDocument();
      expect(selectContainer).toHaveClass('open');

      const selectedDisplay = screen.getByText('one'); /* selected item */
      expect(selectedDisplay).toBeInTheDocument();

      const searchInput = screen.getByPlaceholderText('Filter Host...'); /* placeholder text */
      expect(searchInput).toBeInTheDocument();
      expect(searchInput).toHaveValue('');

      expect(screen.getByText('host1')).toBeInTheDocument();
      expect(screen.getByText('host2')).toBeInTheDocument();

      const activeOption = document.querySelector('.list-group-item.active'); /* active option */
      expect(activeOption).toBeInTheDocument();
      expect(activeOption).toHaveTextContent('host1');
    })
    it('renders EditorHostSelect with loading state', () => {
      render(<EditorHostSelect {...fixtures.loading} />);

      const loadingContainer = document.querySelector('#select-loading-container');
      expect(loadingContainer).toBeInTheDocument();

      const spinner = document.querySelector('#select-spinner');
      expect(spinner).toBeInTheDocument();
      expect(spinner).toHaveClass('spinner', 'spinner-sm');

      expect(screen.getByText('Loading...')).toBeInTheDocument();
    });
    it('renders not with show false prop', () => {
      render(<EditorHostSelect {...fixtures.default} show={false} />);

      const container = document.querySelector('.pf-c-tabs__item');

      expect(container).not.toBeInTheDocument();
    })
  })
});
