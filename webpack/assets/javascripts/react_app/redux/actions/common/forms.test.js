/* eslint-disable promise/prefer-await-to-then */
import { submitForm } from './forms';
import { mockReset } from '../../../mockRequests';
import { requestData } from './forms.fixtures';
import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'should submitForm': () => submitForm(requestData),
};

describe('form actions', () => {
  testActionSnapshotWithFixtures(fixtures);

  beforeEach(() => {
    document.head.innerHTML = `<meta name="csrf-param" content="authenticity_token" />
     <meta name="csrf-token" content="token123" />`;
  });
  afterEach(() => {
    mockReset();
  });

  it('SubmitForm must include an object item/values', () => {
    expect(() => {
      submitForm();
    }).toThrow();
    expect(() => {
      submitForm({ url: 'http://example.com' });
    }).toThrow();
    expect(() => {
      submitForm({ item: 'Resource' });
    }).toThrow();
    expect(() => {
      submitForm({ values: { a: 1 } });
    }).toThrow();
  });
});
