import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import RadioButton from './RadioButton';

const requiredProps = { input: { some: 'input' } };

const fixtures = {
  'render with default props': { ...requiredProps },
  'render with item': {
    ...requiredProps,
    item: { label: 'some-label', checked: true, value: 'some-value' },
  },
  'render disabled': { ...requiredProps, disabled: true },
};

describe('RadioButton', () =>
  testComponentSnapshotsWithFixtures(RadioButton, fixtures));
