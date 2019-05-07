import { runningInPhantomJS } from './helpers';

/**
 * Whether or not the page is focused (beeing used atm)
 * @return {boolean}
 */
export const doesDocumentHasFocus = () =>
  runningInPhantomJS() || (document.hasFocus ? document.hasFocus() : true);

/**
 * Update title of document
 * @param {String} title - the title
 */
export const updateDocumentTitle = title => {
  document.title = title;
};
