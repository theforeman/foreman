import API from '../API';

export default {
  getHostPowerState(id) {
    API.getHostPowerData(id);
  }
};
