import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import TextFieldInner from './TextFieldInner';

const fixtures = {
  render: {},
  'render with item some props': {
    input: { some: 'input' },
    label: 'some-label',
    type: 'password',
    required: true,
    className: 'some-class-name',
    inputClassName: 'some-input-class',
    meta: { touched: true, error: 'some-error' },
  },
  'render textarea': {
    type: 'textarea',
    input: { some: 'input' },
  },
};

describe('TextFieldInner', () =>
  testComponentSnapshotsWithFixtures(TextFieldInner, fixtures));
