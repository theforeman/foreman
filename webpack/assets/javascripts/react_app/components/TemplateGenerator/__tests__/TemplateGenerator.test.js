import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import TemplateGenerator from '../TemplateGenerator';

const fixtures = {
  'render button if not polling and no errors': {
    data: {
      templateName: 'template',
    },
    polling: false,
    dataUrl: '/data/IDENTIFIER.json',
  },
  'render info alert if polling': {
    data: {
      templateName: 'template',
    },
    polling: true,
    dataUrl: '/data/IDENTIFIER.json',
  },
  'renders errors if there are some': {
    data: {
      templateName: 'template',
    },
    polling: false,
    generatingError: '422 unprocessable entity',
    generatingErrorMessages: [
      { message: 'Eh there was no method error during the render :(' },
    ],
  },
};

describe('TemplateGenerator', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(TemplateGenerator, fixtures));
});
