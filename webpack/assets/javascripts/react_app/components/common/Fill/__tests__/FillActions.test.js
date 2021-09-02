import React from 'react';
import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { registerFillComponent, unregisterFillComponent } from '../FillActions';

const SomeComponent = () => <div> a component </div>;
const fixtures = {
  'should regiser a component': () =>
    registerFillComponent('slot-id', undefined, 'fill-id', SomeComponent, 100),
  'should unregiser a component': () =>
    unregisterFillComponent('slot-id', 'fill-id'),
};

describe('AutoComplete actions', () =>
  testActionSnapshotWithFixtures(fixtures));
