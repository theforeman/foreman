import React from 'react';
import PropTypes from 'prop-types';

const SubstringWrapper = ({ children, substring, Element }) => {
  const regexString = () => {
    try {
      return new RegExp(`(${substring})`, 'gi');
    } catch (e) {
      return substring;
    }
  };
  const spilttedText = () => {
    const parts = children.split(regexString());
    const wrappedText = [];

    for (let i = 0; i < parts.length; i += 2) {
      wrappedText[i] = (
        <React.Fragment key={`${i}-fragment`}>
          {parts[i]}
          {parts[i + 1] && <Element key={i}>{parts[i + 1]}</Element>}
        </React.Fragment>
      );
    }
    return wrappedText;
  };

  return <React.Fragment>{spilttedText()}</React.Fragment>;
};

SubstringWrapper.propTypes = {
  children: PropTypes.string.isRequired,
  substring: PropTypes.string.isRequired,
  Element: PropTypes.node,
};

SubstringWrapper.defaultProps = {
  Element: 'b',
};

export default SubstringWrapper;
