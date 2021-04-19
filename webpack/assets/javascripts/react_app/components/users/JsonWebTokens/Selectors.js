/* eslint-disable camelcase */
import {
  selectAPIStatus,
  selectAPIResponse,
} from '../../../redux/API/APISelectors';
import { JSON_WEB_TOKENS_FORM_SUBMITTED } from './Constants';

export const selectGenerateApiStatus = state =>
  selectAPIStatus(state, JSON_WEB_TOKENS_FORM_SUBMITTED);

export const selectJsonWebToken = state =>
  selectAPIResponse(state, JSON_WEB_TOKENS_FORM_SUBMITTED)?.json_web_token;
