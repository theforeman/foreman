import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import Bookmark from '../Bookmark';

const props = {
  text: 'label',
  query: 'query',
  onClick: () => {},
};

const fixtures = {
  'should render bookmark': {
    ...props,
  },
};

describe('Bookmark', () =>
  testComponentSnapshotsWithFixtures(Bookmark, fixtures));
