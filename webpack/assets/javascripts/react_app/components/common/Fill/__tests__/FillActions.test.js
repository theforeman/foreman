import React from 'react';
import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { registerFillComponent, unregisterFillComponent } from '../FillActions';

const SomeComponent = () => <div> a component </div>;
const fixtures = {
  'should regiser a component': () =>
    registerFillComponent({
      slotId: 'slot-id',
      fillId: 'fill-id',
      component: SomeComponent,
      weight: 100,
    }),
  'should unregiser a component': () =>
    unregisterFillComponent({
      slotId: 'slot-id',
      fillId: 'fill-id',
    }),
};

describe('AutoComplete actions', () =>
  testActionSnapshotWithFixtures(fixtures));
