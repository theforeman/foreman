import React from 'react';
import { getColumnLabel, getColumnHelpers, getHeaderModifier, getHeaderStyle, getCellModifier } from './helpers';

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

describe('getHeaderModifier', () => {
  test('keeps 1-word titles on one line', () => {
    expect(getHeaderModifier({ title: 'Name' }, 'name')).toBe('nowrap');
  });

  test('wraps 2-word titles', () => {
    expect(getHeaderModifier({ title: 'Host group' }, 'hostgroup')).toBe(
      'wrap'
    );
  });

  test('truncates 3+ word titles', () => {
    expect(
      getHeaderModifier(
        { title: 'Content view environments' },
        'content_view_environments'
      )
    ).toBe('truncate');
  });

  test('uses an explicit headerModifier over word count', () => {
    expect(
      getHeaderModifier(
        { title: 'Name', headerModifier: 'truncate' },
        'name'
      )
    ).toBe('truncate');
  });

  test('counts words from a React title node via getColumnLabel', () => {
    expect(
      getHeaderModifier({ title: <span>Type</span> }, 'bootc_booted_image')
    ).toBe('nowrap');
  });
});

describe('getHeaderStyle', () => {
  test('uses 12ch for wrap and 16ch for truncate', () => {
    expect(getHeaderStyle({}, 'wrap')).toEqual({ maxWidth: '12ch' });
    expect(getHeaderStyle({}, 'truncate')).toEqual({ maxWidth: '16ch' });
    expect(getHeaderStyle({}, 'nowrap')).toBeUndefined();
  });

  test('uses column.headerMaxWidth when set', () => {
    expect(getHeaderStyle({ headerMaxWidth: '20ch' }, 'wrap')).toEqual({
      maxWidth: '20ch',
    });
  });
});

describe('getCellModifier', () => {
  test('defaults to wrap so overflowing strings fold', () => {
    expect(getCellModifier({ title: 'Name' })).toBe('wrap');
    expect(getCellModifier(undefined)).toBe('wrap');
  });

  test('uses an explicit cellModifier', () => {
    expect(getCellModifier({ cellModifier: 'truncate' })).toBe('truncate');
    expect(getCellModifier({ cellModifier: 'breakWord' })).toBe('breakWord');
    expect(getCellModifier({ cellModifier: 'nowrap' })).toBe('nowrap');
  });

  test('ignores unknown cellModifier values', () => {
    expect(getCellModifier({ cellModifier: 'clip' })).toBe('wrap');
  });
});
