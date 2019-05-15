/* eslint-disable promise/prefer-await-to-then */
import { saveAs } from 'file-saver';
import { API } from '../../../redux/API';
import { runActionInDepth } from '../../../common/testHelpers';

import {
  dataUrl,
  failResponseMock,
  scheduleResponse,
  noContentResponse,
  generatedReportResponse,
} from './TemplateGenerator.fixtures';
import {
  TEMPLATE_GENERATE_REQUEST,
  TEMPLATE_GENERATE_POLLING,
  TEMPLATE_GENERATE_SUCCESS,
  TEMPLATE_GENERATE_FAILURE,
} from '../TemplateGeneratorConstants';
import * as actions from '../TemplateGeneratorActions';

jest.mock('file-saver');
jest.mock('../../../redux/API');

beforeEach(() => {
  API.post.mockImplementation(async () => scheduleResponse);
  API.get.mockImplementation(async () => noContentResponse);
});

describe('TemplateGeneratorActions', () => {
  beforeEach(() => {
    API.post.mockClear();
    API.get.mockClear();
  });

  describe('generateTemplate', () => {
    it('schedule generation', () => {
      runActionInDepth(() =>
        actions.generateTemplate('/schedule', { foo: 'bar' })
      ).then(callTree => {
        expect(callTree[0].type).toEqual(TEMPLATE_GENERATE_REQUEST);
        expect(callTree[0].payload).toHaveProperty('foo', 'bar');
        expect(API.post).toHaveBeenCalledWith('/schedule', { foo: 'bar' });
      });
    });

    it('starts polling', () => {
      runActionInDepth(() => actions.generateTemplate(), 2).then(callTree => {
        expect(callTree[1][0].type).toEqual(TEMPLATE_GENERATE_POLLING);
        expect(callTree[1][0].payload).toHaveProperty('url', dataUrl);
        expect(API.get.mock.calls[0]).toEqual([dataUrl, expect.any(Object)]);
      });
    });

    it('repeats polling till result ready', () => {
      API.get
        .mockImplementationOnce(async () => noContentResponse)
        .mockImplementationOnce(async () => generatedReportResponse);

      runActionInDepth(() => actions.generateTemplate(), 3).then(callTree => {
        const successAction = callTree[1][1][1];
        expect(successAction).toHaveProperty('type', TEMPLATE_GENERATE_SUCCESS);
        expect(saveAs).toHaveBeenCalled();
      });
    });

    it('handle schedule fail', () => {
      API.post.mockImplementation(failResponseMock);

      runActionInDepth(() => actions.generateTemplate()).then(callTree => {
        expect(callTree[1].type).toEqual(TEMPLATE_GENERATE_FAILURE);
        expect(callTree[1].payload).toHaveProperty('error');
      });
    });

    it('handle poll fail', () => {
      API.get.mockImplementation(failResponseMock);

      runActionInDepth(() => actions.generateTemplate(), 2).then(callTree => {
        expect(callTree[1][1].type).toEqual(TEMPLATE_GENERATE_FAILURE);
        expect(callTree[1][1].payload).toHaveProperty('error');
      });
    });
  });
});
