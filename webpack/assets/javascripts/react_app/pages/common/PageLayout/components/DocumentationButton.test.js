import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import DocumentationButton from './DocumentationButton';

const fixtures = {
  'render with minimal props': { url: 'url' },
};

describe('DocumentationButton', () =>
  testComponentSnapshotsWithFixtures(DocumentationButton, fixtures));
