import axios from 'axios';
import { MockAdapter } from '@theforeman/test';

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
  status = 200,
  response = null,
}) => mock[methods[method]](url, data).reply(status, response);

export const mockReset = () => mock.reset();
