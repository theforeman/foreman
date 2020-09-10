import React from 'react';
import { IntegrationTestHelper } from '@theforeman/test';

import { onError } from '../../../../redux/actions/common/forms';

import { initialValues, FormComponent } from './ForemanForm.fixtures';

const nameErrors = ['is too long', 'should not contain numbers'];
const baseErrors = [
  'does not have enough vitamins',
  'does not have enough proteins',
];

const severity = 'warning';

const invalidSubmit = () =>
  new Promise(() =>
    onError({
      response: {
        status: 422,
        data: {
          error: {
            errors: {
              name: nameErrors,
              base: baseErrors,
            },
            severity,
          },
        },
      },
    })
  );

const props = {
  submitForm: invalidSubmit,
  onCancel: () => {},
  initValues: initialValues,
};

describe('ForemanForm integration test', () => {
  it('should render form with errors', async () => {
    const testHelper = new IntegrationTestHelper({});

    const component = testHelper.mount(<FormComponent {...props} />);

    const submitBtn = component.find('Button[bsStyle="primary"]');
    submitBtn.simulate('submit');
    await IntegrationTestHelper.flushAllPromises();
    component.update();

    const formError = component.find('Form').prop('error');

    expect(formError.errorMsgs).toBe(baseErrors);
    expect(formError.severity).toBe(severity);

    expect(component.find('Alert')).toMatchSnapshot();
  });
});
