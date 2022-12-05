import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { groupBy } from 'lodash';
import {
  MenuItem,
  Divider,
  MenuGroup,
  MenuList,
  ClipboardCopy,
} from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';

export const AutoCompleteMenu = ({ results, error }) => {
  if (error) {
    return (
      <MenuList>
        <MenuItem component="span">
          <ClipboardCopy
            isBlock
            isReadOnly
            variant="inline-compact"
            hoverTip={__('Copy to clipboard')}
            clickTip={__('Copied to clipboard')}
          >
            {__('Error:')} {error}
          </ClipboardCopy>
        </MenuItem>
      </MenuList>
    );
  }
  if (results && results.length === 0) {
    return null;
  }
  let itemIndex = 0;
  const grouped = groupBy(results, r => r.category);
  const getMenuItemsByCategory = category =>
    grouped[category].map(({ label }) => {
      const item = (
        <MenuItem key={itemIndex} itemId={label} position={itemIndex}>
          {label}
        </MenuItem>
      );
      itemIndex += 1;
      return item;
    });
  const items = Object.keys(grouped)
    .sort()
    .map(category => (
      <Fragment key={`${category}-fragment`}>
        {!!itemIndex && <Divider key={`${category}-divider`} />}
        <MenuGroup label={category} key={category}>
          <MenuList>{getMenuItemsByCategory(category)}</MenuList>
        </MenuGroup>
      </Fragment>
    ));
  return items;
};

AutoCompleteMenu.propTypes = {
  results: PropTypes.arrayOf(
    PropTypes.shape({ label: PropTypes.string, category: PropTypes.string })
  ),
  error: PropTypes.string,
};

AutoCompleteMenu.defaultProps = {
  results: [],
  error: null,
};
