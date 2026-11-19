import React from 'react';
import { act, fireEvent, render, screen, within } from '@testing-library/react';
import '@testing-library/jest-dom';
import { flushPatternflyTimers } from '../../../../common/rtlTestHelpers';
import TaxonomyDropdown from './TaxonomyDropdown';

const locations = [
  { id: 2, title: 'london', href: '/locations/2-london/select' },
  { id: 3, title: 'norway', href: '/locations/3-norway/select' },
  { id: 4, title: 'nairobi', href: '/locations/4-nairobi/select' },
];

const assign = jest.fn();
const originalLocation = window.location;

beforeAll(() => {
  Object.defineProperty(window, 'location', {
    value: { assign },
    writable: true,
  });
});
afterAll(() => {
  window.location = originalLocation;
});
beforeEach(() => assign.mockClear());

const openDropdown = async toggleText => {
  await act(async () => {
    fireEvent.click(screen.getByRole('button', { name: toggleText }));
  });
  await flushPatternflyTimers();
};

describe('TaxonomyDropdown', () => {
  it('shows the current taxonomy in the toggle and starts closed', () => {
    render(
      <TaxonomyDropdown
        taxonomyType="location"
        currentTaxonomy="london"
        taxonomies={locations}
      />
    );
    const toggle = screen.getByRole('button', { name: /london/ });
    expect(toggle).toHaveAttribute('aria-expanded', 'false');
    expect(screen.queryByRole('menuitem')).not.toBeInTheDocument();
  });

  it('renders the menu inside the #<type>-dropdown container', async () => {
    const { container } = render(
      <TaxonomyDropdown
        taxonomyType="location"
        currentTaxonomy="london"
        taxonomies={locations}
      />
    );
    await openDropdown(/london/);
    const wrapper = container.querySelector('#location-dropdown');
    expect(
      within(wrapper).getByRole('menuitem', { name: /norway/ })
    ).toBeInTheDocument();
  });

  it('lists any-location and all taxonomies, current one disabled', async () => {
    render(
      <TaxonomyDropdown
        taxonomyType="location"
        currentTaxonomy="london"
        taxonomies={locations}
      />
    );
    await openDropdown(/london/);
    expect(
      screen.getByRole('menuitem', { name: /Any location/ })
    ).toBeEnabled();
    expect(screen.getByRole('menuitem', { name: /london/ })).toBeDisabled();
    expect(screen.getByRole('menuitem', { name: /norway/ })).toBeEnabled();
    expect(screen.getByRole('menuitem', { name: /norway/ })).toHaveClass(
      'location_menuitem'
    );
  });

  it('navigates to the taxonomy href on click', async () => {
    render(
      <TaxonomyDropdown
        taxonomyType="location"
        currentTaxonomy="london"
        taxonomies={locations}
      />
    );
    await openDropdown(/london/);
    await act(async () => {
      fireEvent.click(screen.getByRole('menuitem', { name: /norway/ }));
    });
    await flushPatternflyTimers();
    expect(assign).toHaveBeenCalledWith('/locations/3-norway/select');
  });

  it('navigates to the clear URL for any location', async () => {
    render(
      <TaxonomyDropdown
        taxonomyType="location"
        currentTaxonomy="london"
        taxonomies={locations}
      />
    );
    await openDropdown(/london/);
    await act(async () => {
      fireEvent.click(screen.getByRole('menuitem', { name: /Any location/ }));
    });
    await flushPatternflyTimers();
    expect(assign).toHaveBeenCalledWith('/locations/clear');
  });

  it('filters the list by the search text, case-insensitively', async () => {
    render(
      <TaxonomyDropdown
        taxonomyType="location"
        currentTaxonomy="london"
        taxonomies={locations}
      />
    );
    await openDropdown(/london/);
    await act(async () => {
      fireEvent.change(screen.getByRole('textbox'), {
        target: { value: 'NA' },
      });
    });
    await flushPatternflyTimers();
    expect(
      screen.getByRole('menuitem', { name: /nairobi/ })
    ).toBeInTheDocument();
    expect(
      screen.queryByRole('menuitem', { name: /norway/ })
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole('menuitem', { name: /london/ })
    ).not.toBeInTheDocument();
  });

  it('shows any-organization in the toggle when no taxonomy is selected', async () => {
    render(<TaxonomyDropdown taxonomyType="organization" taxonomies={[]} />);
    await openDropdown(/Any organization/);
    expect(
      screen.getByRole('menuitem', { name: /Any organization/ })
    ).toBeDisabled();
  });

  it('links to the manage page in the footer', async () => {
    render(
      <TaxonomyDropdown
        taxonomyType="organization"
        currentTaxonomy="org1"
        taxonomies={[]}
      />
    );
    await openDropdown(/org1/);
    expect(
      screen.getByRole('link', { name: 'Manage Organizations' })
    ).toHaveAttribute('href', '/organizations');
  });

  it('focuses the filter field when the menu opens', async () => {
    render(
      <TaxonomyDropdown
        taxonomyType="location"
        currentTaxonomy="london"
        taxonomies={locations}
      />
    );
    await openDropdown(/london/);
    expect(screen.getByRole('textbox')).toHaveFocus();
  });

  it('keeps the menu open on Tab so the filter and footer stay reachable', async () => {
    render(
      <TaxonomyDropdown
        taxonomyType="location"
        currentTaxonomy="london"
        taxonomies={locations}
      />
    );
    await openDropdown(/london/);
    await act(async () => {
      fireEvent.keyDown(screen.getByRole('textbox'), { key: 'Tab' });
    });
    await flushPatternflyTimers();
    expect(screen.getByRole('button', { name: /london/ })).toHaveAttribute(
      'aria-expanded',
      'true'
    );
    expect(
      screen.getByRole('link', { name: 'Manage Locations' })
    ).toBeInTheDocument();
  });
});
