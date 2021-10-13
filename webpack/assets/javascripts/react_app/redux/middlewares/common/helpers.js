/**
 * Executes a callback when the document is visible.
 * Used to decrease load when tab is hidden, for example when intervals are running.
 * @param { Function } callback
 */
export const whenDocumentIsVisible = (callback) => {
  const { hidden, msHidden, webkitHidden } = document;
  let isHidden = true;
  const isNotUndefined = (n) => typeof n !== 'undefined';

  if (isNotUndefined(hidden)) {
    // Opera 12.10 and Firefox 18 and later support
    isHidden = hidden;
  } else if (isNotUndefined(msHidden)) {
    isHidden = msHidden;
  } else if (isNotUndefined(webkitHidden)) {
    isHidden = webkitHidden;
  }

  if (!isHidden) {
    callback();
  }
};
