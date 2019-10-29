import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import TextField from './TextField';

const commonFixture = {
  name: 'name',
  label: 'Name',
};

const fixtures = {
  'should default to a text field': {
    type: 'text',
    ...commonFixture,
  },
  'should render a text area': {
    type: 'textarea',
    ...commonFixture,
  },
  'should render a checkbox': {
    type: 'checkbox',
    ...commonFixture,
  },
};

describe('TextField', () =>
  testComponentSnapshotsWithFixtures(TextField, fixtures));
