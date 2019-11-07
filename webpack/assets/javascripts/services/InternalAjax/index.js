import $ from 'jquery';
import API from '../../react_app/API';
import { showSpinner, hideSpinner } from '../../foreman_tools';
import { ApplyLinks } from '../../foreman_navigation';

let cachedHead = null;

export const contentSwaping = async url => {
  cachedHead = cachedHead || getInitialHead();
  let response = null;
  showSpinner();
  try {
    response = await API.get(url, { Accept: 'text/html' });
  } catch ({ response: { status } }) {
    window.location.assign(status);
  }

  const { data } = response;
  const railsContent = $('#content');
  const [parsedContent, parsedHead] = parsingHTML(data);

  if (compareHeads(parsedHead, cachedHead)) {
    railsContent.replaceWith(parsedContent);
    // eslint-disable-next-line jquery/no-show
    $('#content').show();
  } else {
    window.location.assign(url);
  }
  hideSpinner();
  cachedHead = parsedHead;
  ApplyLinks();
  $(document.body).trigger('ContentLoad');
};

const parsingHTML = html => {
  // eslint-disable-next-line jquery/no-parse-html
  const domParser = new DOMParser();
  const parsed = $($.parseHTML(html, document, true));
  const parsedContent = parsed.find('#content')[0];

  const doc = domParser.parseFromString(html, 'text/html');
  const trackedHead = getTrackedTags(doc.head);
  return [parsedContent, trackedHead];
};

const getTrackedTags = document =>
  document.querySelectorAll('[data-turbolinks-track]');

const compareHeads = (newHead, currentHead) => {
  if (newHead.length !== currentHead.length) return false;
  let isEqual = true;
  currentHead.forEach((elm, index) => {
    if (!newHead[index].isEqualNode(elm)) {
      isEqual = false;
    }
  });
  return isEqual;
};

const getInitialHead = () => getTrackedTags($('head')[0]);
