/**
 * Whether or not the page is focused (beeing used atm)
 * @return {boolean}
 */
export const doesDocumentHasFocus = () =>
  document.hasFocus ? document.hasFocus() : true;
