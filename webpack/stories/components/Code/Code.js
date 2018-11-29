import React from 'react';
import PropTypes from 'prop-types';
import hljs from 'highlight.js';
import './Code.scss';

const Code = ({ children, lang }) => {
  if (lang !== undefined) {
    const highlightedCode = hljs.highlight(lang, children).value;
    return <pre dangerouslySetInnerHTML={{ __html: highlightedCode }} />;
  }

  return <pre>{children}</pre>;
};

Code.propTypes = {
  lang: PropTypes.string.isRequired,
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]).isRequired,
};

export default Code;
