import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import { ActionButtons } from './ActionButtons';
import { buttons } from './ActionButtons.fixtures';

const fixtures = {
  'renders ActionButtons with 0 button': { buttons: [] },
  'renders ActionButtons with 1 button': { buttons: [buttons[0]] },
  'renders ActionButtons with 3 button': { buttons },
};

describe('ActionButtons', () =>
  testComponentSnapshotsWithFixtures(ActionButtons, fixtures));
