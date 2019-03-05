import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';

import {
  TEMPLATE_GENERATE_REQUEST,
  TEMPLATE_GENERATE_POLLING,
  TEMPLATE_GENERATE_SUCCESS,
  TEMPLATE_GENERATE_FAILURE,
} from '../TemplateGeneratorConstants';
import { dataUrl } from './TemplateGenerator.fixtures';
import reducer from '../TemplateGeneratorReducer';

const fixtures = {
  'returns the initial state': {},
  'handles TEMPLATE_GENERATE_REQUEST': {
    action: {
      type: TEMPLATE_GENERATE_REQUEST,
    },
  },
  'should handle TEMPLATE_GENERATE_POLLING': {
    action: {
      type: TEMPLATE_GENERATE_POLLING,
      payload: { url: dataUrl },
    },
  },
  'should handle TEMPLATE_GENERATE_SUCCESS': {
    action: {
      type: TEMPLATE_GENERATE_SUCCESS,
    },
  },
  'handles TEMPLATE_GENERATE_FAILURE': {
    action: {
      type: TEMPLATE_GENERATE_FAILURE,
      payload: {
        error: new Error('some error'),
        messages: [{ message: 'It did not went so well' }],
      },
    },
  },
};

describe('TemplateGenerator reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
