import browserUpdate from 'browser-update';
import { runningInPhantomJS } from '../../common/helpers';
import {
  BROWSER_SUPPORT_INITIALIZE,
  BROWSER_SUPPORT_SHOW_BANNER,
} from './BrowserSupportConstants';

export const initializeBanner = () => dispatch => {
  if (runningInPhantomJS()) return;
  dispatch({
    type: BROWSER_SUPPORT_INITIALIZE,
    payload: {
      browserName: window.$bu_getBrowser().t,
    },
  });
  browserUpdate({
    required: {
      i: 12, // obsolete IE completely
      e: -2,
      f: -5,
      o: -5,
      s: -4,
      c: -5,
    },
    test: true, // TODO: Really good idea to delete before merging :thinking:
    nomessage: true,
    insecure: true,
    unsupported: true,
    api: 2019.05,
    onshow: opts => {
      dispatch({
        type: BROWSER_SUPPORT_SHOW_BANNER,
        payload: {},
      });
    },
  });
};
