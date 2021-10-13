import {
  REGISTRATION_COMMANDS_DATA,
  REGISTRATION_COMMANDS_OS_TEMPLATE,
  REGISTRATION_COMMANDS,
} from '../constants';

import {
  selectAPIStatus,
  selectAPIResponse,
} from '../../../redux/API/APISelectors';

// Form API Data

export const selectAPIStatusData = (state) =>
  selectAPIStatus(state, REGISTRATION_COMMANDS_DATA);

export const selectOrganizations = (state) =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).organizations || [];

export const selectLocations = (state) =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).locations || [];

export const selectHostGroups = (state) =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).hostGroups || [];

export const selectOperatingSystems = (state) =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).operatingSystems || [];

export const selectOperatingSystemTemplate = (state) =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_OS_TEMPLATE).template;

export const selectSmartProxies = (state) =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).smartProxies || [];

export const selectConfigParams = (state) =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).configParams || {};

export const selectPluginData = (state) =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).pluginData || {};

// Generate Command

export const selectAPIStatusCommand = (state) =>
  selectAPIStatus(state, REGISTRATION_COMMANDS);

export const selectCommand = (state) =>
  selectAPIResponse(state, REGISTRATION_COMMANDS).command || '';
