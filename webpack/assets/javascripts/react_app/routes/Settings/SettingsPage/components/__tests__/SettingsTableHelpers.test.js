import React from 'react';

import {
  testComponentSnapshotsWithFixtures,
  testSelectorsSnapshotWithFixtures,
} from '@theforeman/test';

import {
  withTooltip,
  valueToString,
  defaultToString,
  inStrong,
} from '../SettingsTableHelpers';

const Component = withTooltip(props => <div>Foo</div>);

const componentFixtures = {
  'should render a component with tooltip': {
    tooltipId: 'tooltip',
    tooltipText: 'This is tooltip',
  },
};

// todo: check the helper for default value
const fixtures = {
  'format boolean value to string': () =>
    valueToString({ value: true, settingsType: 'boolean' }),
  'format array value to string': () =>
    valueToString({ value: ['foo', 'bar'], settingsType: 'array' }),
  'format empty value to string': () => valueToString({ value: null }),
  'format text value': () => valueToString({ value: 'text value' }),
  'format default boolean value to string': () =>
    defaultToString({ default: true, settingsType: 'boolean' }),
  'format default array value to string': () =>
    valueToString({ default: ['foo', 'bar'], settingsType: 'array' }),
  'format default empty value to string': () =>
    valueToString({ default: null }),
  'format default text value': () =>
    valueToString({ default: 'default value' }),
  'should return markup in strong': () => inStrong('Foo'),
};

describe('withTooltip', () =>
  testComponentSnapshotsWithFixtures(Component, componentFixtures));

describe('SettingsTableHelpers', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
