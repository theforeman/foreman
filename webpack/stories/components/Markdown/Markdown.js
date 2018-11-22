import React from 'react';
import PropTypes from 'prop-types';
import hljs from 'highlight.js';
import Remarkable from 'react-remarkable';
import Text from '../Text';
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
    <Text>
      <Remarkable source={source} options={options} />
    </Text>
  );
};

Markdown.propTypes = {
  source: PropTypes.string,
};

Markdown.defaultProps = {
  source: '',
};

export default Markdown;
