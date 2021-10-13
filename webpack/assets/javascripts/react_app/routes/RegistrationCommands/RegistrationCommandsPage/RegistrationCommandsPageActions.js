import { foremanUrl } from '../../../../foreman_tools';
import { get, post } from '../../../redux/API';

import {
  REGISTRATION_COMMANDS_DATA,
  REGISTRATION_COMMANDS_OS_TEMPLATE,
  REGISTRATION_COMMANDS,
} from '../constants';

export const dataAction = (params) =>
  get({
    key: REGISTRATION_COMMANDS_DATA,
    url: foremanUrl('/hosts/register/data'),
    params,
  });

export const operatingSystemTemplateAction = (operatingSystemId) =>
  get({
    key: REGISTRATION_COMMANDS_OS_TEMPLATE,
    url: foremanUrl(`/hosts/register/os/${operatingSystemId}`),
  });

export const commandAction = (params) =>
  post({
    key: REGISTRATION_COMMANDS,
    url: foremanUrl('/hosts/register'),
    params,
  });
