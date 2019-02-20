import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import TemplateGenerator from '../TemplateGenerator';

const fixtures = {
  'do not render link if not polling': {
    data: {
      templateName: 'template',
    },
    polling: false,
    dataUrl: null,
  },
  'render link if polling': {
    data: {
      templateName: 'template',
    },
    polling: true,
    dataUrl: '/data/IDENTIFIER.json',
  },
};

describe('TemplateGenerator', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(TemplateGenerator, fixtures));
});
