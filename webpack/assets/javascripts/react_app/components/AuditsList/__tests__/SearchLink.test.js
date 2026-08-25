import React from 'react';
import { render, screen, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import SearchLink from '../SearchLink';
import { searchLinkProp } from './AuditsList.fixtures';

describe('SearchLink', () => {
  it('renders a search link', () => {
    render(<SearchLink {...searchLinkProp} />);

    const link = screen.getByRole('link', { name: searchLinkProp.textValue });

    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', searchLinkProp.url);
  });

  it('shows the title in a tooltip on hover', async () => {
    render(<SearchLink {...searchLinkProp} />);

    expect(screen.queryByRole('tooltip')).not.toBeInTheDocument();

    await act(async () => {
      await userEvent.hover(
        screen.getByRole('link', { name: searchLinkProp.textValue })
      );
    });

    expect(await screen.findByRole('tooltip')).toHaveTextContent(
      searchLinkProp.title
    );
  });
});
