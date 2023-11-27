import React from 'react';
import { act, render, fireEvent } from '@testing-library/react';
import { NavigationSearch } from '../NavigationSearch';
import { PFitems } from '../Layout.fixtures';

describe('NavigationSearch', () => {
  const items = [
    ...PFitems,
    {
      title: 'test',
      initialActive: true,
      iconClass: 'fa fa-tachometer',
      subItems:   [{
        title: 'Aa', // duplicate title to test filtering
        isDivider: false,
        href: '/aaa',
        id: 'menu_item_aa',
      }],
    },
  ];
  it('should display autocomplete options when input is typed', async () => {
    const {
      queryAllByRole,
      getByPlaceholderText,
      getByRole,
      getByLabelText,
    } = render(
      <div className="pf-c-masthead pf-m-display-inline">
        <NavigationSearch items={items} clickAndNavigate={() => {}} />
      </div>
    );
    const input = getByPlaceholderText('Search and go');
    act(() => input.focus());
    await act(async () => {
      await fireEvent.change(input, { target: { value: 'a' } });
    });
    expect(queryAllByRole('menuitem')).toHaveLength(3);
  });
});
