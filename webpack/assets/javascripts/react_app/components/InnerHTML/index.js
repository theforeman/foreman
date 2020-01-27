import React, { useEffect, useRef } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import DelayedSkeleton from '../DelayedSkeleton';

const DangerouslyInnerHTML = ({ html }) => {
  const divRef = useRef(null);
  const dispatch = useDispatch();
  const isLoading = useSelector(state => state.app.legacyLoading);
  useEffect(() => {
    const newContent = () => {
      const range = document.createRange();
      const parsedHtml = range.createContextualFragment(html);
      return parsedHtml;
    };
    if (html) {
      const oldContent = document.getElementById('content');
      const parsedHtml = newContent();
      if (oldContent) {
        divRef.current.replaceChild(parsedHtml, oldContent);
      } else divRef.current.appendChild(parsedHtml);
    }
  }, [html, dispatch]);
  return (
    <React.Fragment>
      <div
        id="main"
        style={{ display: isLoading ? 'none' : 'inherit' }}
        ref={divRef}
      />
      {isLoading && <DelayedSkeleton count={5} />}
    </React.Fragment>
  );
};

export default DangerouslyInnerHTML;

DangerouslyInnerHTML.propTypes = {
  html: PropTypes.string,
};

DangerouslyInnerHTML.defaultProps = {
  html: '',
};
