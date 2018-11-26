import React from 'react';
import PropTypes from 'prop-types';
import hljs from 'highlight.js';
import Remarkable from 'react-remarkable';
import './Markdown.scss';

const Markdown = ({ source }) => {
  const options = {
    html: true,
    breaks: true,
    linkTarget: '_parent',
    highlight(code, lang) {
      if (lang !== undefined) {
        return hljs.highlight(lang, code).value;
      }
      return '';
    },
  };

  return (
    <div className="markdown-body">
      <Remarkable source={source} options={options} />
    </div>
  );
};

Markdown.propTypes = {
  source: PropTypes.string,
};

Markdown.defaultProps = {
  source: '',
};

export default Markdown;
