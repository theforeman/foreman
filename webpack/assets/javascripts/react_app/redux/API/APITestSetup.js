import axios from 'axios';

// a counter for active requests, like jQuery.active
window.axiosActive = 0;

axios.interceptors.request.use((config) => {
  window.axiosActive += 1;
  return config;
});

axios.interceptors.response.use((response) => {
  window.axiosActive -= 1;
  return response;
});
