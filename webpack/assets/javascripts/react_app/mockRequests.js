import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { HTTP_STATUS_CODES } from './constants';

export const mock = new MockAdapter(axios);
const methods = {
  GET: 'onGet',
  POST: 'onPost',
  PUT: 'onPut',
  DELETE: 'onDelete',
};

export const mockRequest = ({
  method = 'GET',
  url,
  data = null,
  status = HTTP_STATUS_CODES.OK,
  response = null,
}) => mock[methods[method]](url, data).reply(status, response);

export const mockReset = () => mock.reset();
