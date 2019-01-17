import { runningInPhantomJS } from './helpers';

/**
 * Whether or not the page is focused (beeing used atm)
 * @return {boolean}
 */
export const doesDocumentHasFocus = () =>
  runningInPhantomJS() || (document.hasFocus ? document.hasFocus() : true);
