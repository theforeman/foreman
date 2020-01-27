export const getLegacyContent = async (
  location,
  setContent,
  setReload,
  referer
) => {
  let needsReload;
  let doc;

  cleanUp();
  try {
    const data = await fetchLegacyContent(getUrl(location), referer);
    doc = parsingDOM(data);
    const headScripts = getHeadScripts(doc);
    needsReload = compareHeads(headScripts.slice(1));
  } catch (e) {
    setReload(true);
  }

  if (needsReload) {
    setReload(true);
  } else {
    const content = doc.getElementById('content');
    const html = content.outerHTML.concat(
      triggerContentLoad,
      FinishLoadingScript
    );
    setContent(html);
  }
};

const triggerContentLoad = `<script defer="defer"> $(document).trigger('ContentLoad') </script> `;
const FinishLoadingScript = `<script defer="defer"> tfm.nav.updateLegacyLoading(false) </script> `;

const getUrl = ({ pathname, search }) => {
  const url = `${pathname}${search}`;
  // the search has redundant `?` at the end
  return url.endsWith('?') ? url.slice(0, -1) : url;
};

const getHeadScripts = doc => {
  const head = doc.getElementsByTagName('head')[0];
  const headScripts = [...head.getElementsByTagName('script')];
  headScripts.splice(5, 1);
  return headScripts;
};
const parsingDOM = html => {
  const domParser = new DOMParser();
  return domParser.parseFromString(html, 'text/html');
};

const fetchLegacyContent = async (url, referer) => {
  const response = await fetch(url, {
    method: 'GET',
    referrer: referer,
    headers: { Accept: 'text/html' },
  });
  const data = await response.text();
  return data;
};

const cleanUp = () => {
  // runtime error when importing `umountAllComponents`, works with tfm
  window.tfm.reactMounter.umountAllComponents();
  const railsContainer = document.getElementById('content');
  if (railsContainer) railsContainer.remove();
};

// Compare the new head with the current one, if a new script has discovered - triggers a full page reload
// TODO: This can be removed as soon as all `javascript('file')` will be removed from erb files
const compareHeads = currentHead => {
  const previousHead = getPreviousHead();
  if (previousHead.length !== currentHead.length) return true;
  return currentHead.some(
    (script, index) => !script.isEqualNode(previousHead[index])
  );
};

const getPreviousHead = () => {
  const prevHeadScripts = [...document.head.getElementsByTagName('script')];
  prevHeadScripts.splice(5, 1); // remove hard coded auth token
  return prevHeadScripts.slice(1); // Remove async i18n script
};
