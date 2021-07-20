import axios from 'axios';
import './APITestSetup';

const getcsrfToken = () => {
  const token = document.querySelector('meta[name="csrf-token"]');

  return token ? token.content : '';
};

axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
axios.defaults.headers.common['X-CSRF-Token'] = getcsrfToken();

export default {
  get(url, headers = {}, params = {}) {
    return axios.get(url, {
      headers,
      params,
    });
  },
  put(url, data = {}, headers = {}) {
    return axios.put(url, data, {
      headers,
    });
  },
  post(url, data = {}, headers = {}) {
    return axios.post(url, data, {
      headers,
    });
  },
  delete(url, headers = {}) {
    return axios.delete(url, {
      headers,
    });
  },
  patch(url, data = {}, headers = {}) {
    return axios.patch(url, data, {
      headers,
    });
  },
};
