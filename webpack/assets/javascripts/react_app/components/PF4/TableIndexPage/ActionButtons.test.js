import React from 'react';
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from '@testing-library/react';
import '@testing-library/jest-dom';
import { flushPatternflyTimers } from '../../../common/rtlTestHelpers';

import { ActionButtons } from './ActionButtons';

const openKebab = async () => {
  await act(async () => {
    fireEvent.click(
      screen.getByRole('button', { name: 'toggle action dropdown' })
    );
  });
  await flushPatternflyTimers();
};

describe('TableIndexPage ActionButtons', () => {
  it('renders nothing without buttons', () => {
    const { container } = render(<ActionButtons buttons={[]} />);
    expect(container).toBeEmptyDOMElement();
  });

  it('renders the first button as a link when it has an href', () => {
    render(
      <ActionButtons
        buttons={[{ title: 'Create new', action: { href: '/hosts/new' } }]}
      />
    );
    expect(screen.getByRole('link', { name: 'Create new' })).toHaveAttribute(
      'href',
      '/hosts/new'
    );
    expect(
      screen.queryByRole('button', { name: 'toggle action dropdown' })
    ).not.toBeInTheDocument();
  });

  it('puts the remaining buttons in a kebab menu', async () => {
    const onImport = jest.fn();
    render(
      <ActionButtons
        buttons={[
          { title: 'Create new', action: { href: '/hosts/new' } },
          {
            title: 'Export',
            action: { href: '/hosts.csv', 'data-method': 'get' },
          },
          { title: 'Import', action: { onClick: onImport } },
        ]}
      />
    );
    expect(screen.queryByText('Export')).not.toBeInTheDocument();
    await openKebab();

    const exportItem = screen.getByRole('menuitem', { name: 'Export' });
    expect(exportItem.tagName).toBe('A');
    expect(exportItem).toHaveAttribute('href', '/hosts.csv');
    expect(exportItem).toHaveAttribute('data-method', 'get');

    await act(async () => {
      fireEvent.click(screen.getByRole('menuitem', { name: 'Import' }));
    });
    await flushPatternflyTimers();
    expect(onImport).toHaveBeenCalledTimes(1);
    expect(
      screen.getByRole('button', { name: 'toggle action dropdown' })
    ).toHaveAttribute('aria-expanded', 'false');
    await waitFor(() =>
      expect(screen.queryByText('Import')).not.toBeInTheDocument()
    );
  });
});
