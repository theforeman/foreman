import React from 'react';
import PropTypes from 'prop-types';
import { Tooltip } from '@patternfly/react-core';

const SearchLink = ({ url, title, id, textValue }) => {
  const linkProps = {
    href: url,
    id: `resource-link-${id}`,
  };

  return (
    <Tooltip
      content={
        <div>
          <div>{title}</div>
          <div>
            <a {...linkProps}>{textValue}</a>
          </div>
        </div>
      }
      position="top-start"
    >
      <a {...linkProps}>{textValue}</a>
    </Tooltip>
  );
};

SearchLink.propTypes = {
  url: PropTypes.string.isRequired,
  id: PropTypes.number.isRequired,
  title: PropTypes.string,
  textValue: PropTypes.string,
};

SearchLink.defaultProps = {
  title: undefined,
  textValue: '',
};

export default SearchLink;
