import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import LabelIcon from './index';

describe('LabelIcon', () => {
  testComponentSnapshotsWithFixtures(LabelIcon, { 'renders': {text: 'Yay, label help!'} });
})
