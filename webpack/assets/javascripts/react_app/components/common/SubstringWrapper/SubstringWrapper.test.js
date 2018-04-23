import SubstringWrapper from './';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'should render with b tag': {
    substring: 'test',
    children: 'this is a test',
  },
  'should wrap twice': {
    substring: 'test',
    children: 'test - this is a test',
  },
  'should wrap with another element': {
    Element: 'i',
    substring: 'test',
    children: 'this is a test',
  },
  'substring is not found': {
    Element: 'i',
    substring: 'test',
    children: 'this is a SubstringWrapper component',
  },
  'should work if regex failed': {
    substring: '*',
    children: 'this is a test',
  },
};

describe('SubstringWrapper', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(SubstringWrapper, fixtures));
});
