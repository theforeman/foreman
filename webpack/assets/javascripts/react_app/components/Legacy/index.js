import React, { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { isEqual } from 'lodash';
import { selectReferer } from '../../ReactApp/ReactAppSelectors';
import DangerouslyInnerHTML from '../InnerHTML';
import { getLegacyContent } from './helpers';

const LegacyContent = ({ location }) => {
  const [content, setContent] = useState(null);
  const [reload, setReload] = useState(false);
  // The server needs the referer header for redirection
  const referer = useSelector(selectReferer);
  const { pathname, search } = location;

  useEffect(() => {
    /* When a referer exists, no need for full page reload
       an ajax call occours for getting new legacy content is invoked */
    if (referer) getLegacyContent(location, setContent, setReload, referer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [location]);

  useEffect(() => {
    // triggres a full page reload when needed
    reload && window.location.assign(`${pathname}${search}`);
  }, [pathname, search, reload]);
  return !reload && referer && <DangerouslyInnerHTML html={content} />;
};

const areEqual = ({ location: prevLocation }, { location: nextLocation }) => {
  // This was created for memorizing legacy content when the same location is requested
  delete prevLocation.key;
  delete nextLocation.key;
  const { key: key1, ...prevLocWithoutKey } = prevLocation;
  const { key: key2, ...nextLocWithoutKey } = nextLocation;

  return isEqual(prevLocWithoutKey, nextLocWithoutKey);
};

export default React.memo(LegacyContent, areEqual);

LegacyContent.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string,
    search: PropTypes.string,
  }).isRequired,
};
