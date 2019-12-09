import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import RadioButtonGroup from './RadioButtonGroup';

const radios = [
  {
    label: 'A',
    checked: true,
    value: 'A',
  },
  {
    label: 'B',
    checked: false,
    value: 'B',
  },
];

const commonFixtures = {
  name: "RadioButtonGroupTest",
  controlLabel: "RadioButtonGroupLabel",
};

const fixtures = {
  'should render group of radio buttons': {
    radios,
    ...commonFixtures,
  },
  'should render disabled radio buttons': {
    radios,
    ...commonFixtures,
    disabled: true,
  }
};

describe('radio button group', () =>
  testComponentSnapshotsWithFixtures(RadioButtonGroup, fixtures));
