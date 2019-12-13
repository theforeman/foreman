import {
  testComponentSnapshotsWithFixtures,
  testSelectorsSnapshotWithFixtures,
} from '@theforeman/test';
import * as Yup from 'yup';

import { prepareErrors, isInitialValid } from './ForemanForm';
import {
  initialValues,
  FormComponent,
  validationSchema,
} from './ForemanForm.fixtures';

const fixtures = {
  'render foreman form with fields': {
    submitForm: () => {},
    initValues: initialValues,
    schema: validationSchema,
    onCancel: () => {},
  },
};

const basicSchema = Yup.object().shape({
  name: Yup.string().required('is required'),
});

const helperFixtures = {
  'should format errors': () =>
    prepareErrors({
      errors: {
        name: ['is already taken', 'is too short'],
        email: ['is not a valid format'],
        phone: ['is too long'],
      },
    }),
  'should recognize valid initial values': () =>
    isInitialValid({
      validationSchema: basicSchema,
      initialValues: { name: 'George' },
    }),
  'should recognize invalid initial values': () =>
    isInitialValid({ validationSchema: basicSchema, initialValues: {} }),
};

describe('ForemanForm', () => {
  testComponentSnapshotsWithFixtures(FormComponent, fixtures);
});

describe('Foreman form helper functions', () =>
  testSelectorsSnapshotWithFixtures(helperFixtures));
