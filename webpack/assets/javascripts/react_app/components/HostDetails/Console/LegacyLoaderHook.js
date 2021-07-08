import { useState, useEffect, useRef } from 'react';
import { STATUS } from '../../../constants';
import { getApiResponse } from '../../../redux/API/APIHelpers';

/**
 * A custom hook for ajax requests, returns html content to be wrapped in a react component
 * @param  {string} type the  method for the ajax request (i.e 'post', 'get' etc)
 * @param  {string} url the url for the ajax request
 * @param  {object} options DOM manipulation helpers
 * @return {object} returns an object that contains the request's status and the parsed html to renderd in 'dangerouslySetInnerHTML'
 */

export const useDangerouslyLegacy = (
  type,
  url,
  { chosenElement, elementsToRemove } = {}
) => {
  const [parsedHTML, setParsedHTML] = useState();
  const [rawHTML, setRawHTML] = useState();
  const [status, setStatus] = useState(STATUS.PENDING);

  // constants
  const { current: _elementsToRemove } = useRef(elementsToRemove);

  useEffect(() => {
    if (url) {
      const fetchLegacy = async () => {
        try {
          const { data } = await getApiResponse({
            type,
            url,
          });
          setRawHTML(data);
          setStatus(STATUS.RESOLVED);
        } catch (err) {
          setStatus(STATUS.ERROR);
        }
      };
      fetchLegacy();
    }
  }, [url, type]);

  useEffect(() => {
    if (rawHTML) {
      const parser = new DOMParser();
      const doc = parser.parseFromString(rawHTML, 'text/html');
      let html;
      if (_elementsToRemove) {
        removeElements(doc, _elementsToRemove);
        html = doc.documentElement.innerHTML;
      }
      if (chosenElement) {
        html = doc.getElementById(chosenElement).outerHTML;
      }
      setParsedHTML(html || rawHTML);
    }
  }, [rawHTML, _elementsToRemove, chosenElement]);

  return {
    status,
    html: parsedHTML,
  };
};

const removeElements = (doc, removalList) => {
  // https://github.com/eslint/eslint/issues/12117
  // eslint-disable-next-line no-unused-vars
  for (const id of removalList) {
    const element = doc.getElementById(id);
    if (element) element.remove();
  }
};
