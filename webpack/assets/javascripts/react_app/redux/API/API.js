import axios from 'axios';
import './APITestSetup';
import { foremanUrl } from '../../../foreman_tools';

const getcsrfToken = () => {
  const token = document.querySelector('meta[name="csrf-token"]');

  return token ? token.content : '';
};

axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
axios.defaults.headers.common['X-CSRF-Token'] = getcsrfToken();

export default {
  get(url, headers = {}, params = {}) {
    return axios.get(foremanUrl(url), {
      headers,
      params,
    });
  },
  put(url, data = {}, headers = {}) {
    return axios.put(foremanUrl(url), data, {
      headers,
    });
  },
  post(url, data = {}, headers = {}) {
    return axios.post(foremanUrl(url), data, {
      headers,
    });
  },
  delete(url, headers = {}) {
    return axios.delete(foremanUrl(url), {
      headers,
    });
  },
  patch(url, data = {}, headers = {}) {
    return axios.patch(foremanUrl(url), data, {
      headers,
    });
  },
};
