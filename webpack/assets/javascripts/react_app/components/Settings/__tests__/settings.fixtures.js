import Immutable from 'seamless-immutable';

export const successResponse = Immutable({
  value: false,
  description:
    'A server operating in disconnected mode does not communicate with the Red Hat CDN.',
  category: 'Setting::Content',
  settings_type: 'boolean',
  default: false,
  created_at: '2018-03-09 10:58:34 -0500',
  updated_at: '2018-05-07 22:46:58 -0400',
  id: 146,
  name: 'content_disconnected',
  category_name: 'Content',
});

export const getSuccessActions = [
  {
    type: 'GET_SETTING_REQUEST',
  },
  {
    response: successResponse,
    type: 'GET_SETTING_SUCCESS',
  },
];

export const getFailureActions = [
  {
    type: 'GET_SETTING_REQUEST',
  },
  {
    result: new Error('Request failed with status code 422'),
    type: 'GET_SETTING_FAILURE',
  },
];
