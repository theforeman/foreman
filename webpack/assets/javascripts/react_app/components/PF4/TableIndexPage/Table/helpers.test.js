import React from 'react';
import { getColumnLabel, getColumnHelpers } from './helpers';

describe('getColumnLabel', () => {
  test('uses a string title', () => {
    expect(getColumnLabel({ title: 'Type' }, 'bootc_booted_image')).toBe(
      'Type'
    );
  });

  test('prefers an explicit label over title', () => {
    expect(
      getColumnLabel({ title: 'Wrong', label: 'Type' }, 'bootc_booted_image')
    ).toBe('Type');
  });

  test('extracts string children from a React title node', () => {
    expect(
      getColumnLabel(
        { title: <span title="Image mode / package mode">Type</span> },
        'bootc_booted_image'
      )
    ).toBe('Type');
  });

  test('falls back to the column key when title is a non-string without text children', () => {
    expect(getColumnLabel({ title: <span /> }, 'bootc_booted_image')).toBe(
      'bootc_booted_image'
    );
  });
});


describe('getColumnHelpers', () => {
  test('maps keys to string labels even when title is a React node', () => {
    const columns = {
      bootc_booted_image: {
        title: <span>Type</span>,
        weight: 1,
      },
      name: {
        title: 'Name',
        weight: 2,
      },
    };
    const [keys, labels] = getColumnHelpers(columns);
    expect(keys).toEqual(['bootc_booted_image', 'name']);
    expect(labels.bootc_booted_image).toBe('Type');
    expect(labels.name).toBe('Name');
    expect(typeof labels.bootc_booted_image).toBe('string');
  });
});
