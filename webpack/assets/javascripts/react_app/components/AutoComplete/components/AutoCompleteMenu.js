import React from 'react';
import PropTypes from 'prop-types';
import groupBy from 'lodash/groupBy';
import { TypeAheadSelect } from 'patternfly-react';
import SubstringWrapper from '../../common/SubstringWrapper';

const { Menu, MenuItem } = TypeAheadSelect;

const AutoCompleteMenu = ({ results, menuProps }) => {
  let itemIndex = 0;
  const grouped = groupBy(results, r => r.category);
  const getMenuItemsByCategory = category =>
    grouped[category].map((result) => {
      const item = (
        <MenuItem key={itemIndex} option={result.label} position={itemIndex}>
          <SubstringWrapper substring={menuProps.text}>{result.label}</SubstringWrapper>
        </MenuItem>
      );
      itemIndex += 1;
      return item;
    });
  const items = Object.keys(grouped)
    .sort()
    .map(category => (
      <React.Fragment key={`${category}-fragment`}>
        {!!itemIndex && <Menu.Divider key={`${category}-divider`} />}
        <Menu.Header key={`${category}-header`}>{category}</Menu.Header>
        {getMenuItemsByCategory(category)}
      </React.Fragment>
    ));
  return <Menu {...menuProps}>{items}</Menu>;
};

AutoCompleteMenu.propTypes = {
  results: PropTypes.array,
  menuProps: PropTypes.object,
};

AutoCompleteMenu.defaultProps = {
  results: [],
  menuProps: {},
};

export default AutoCompleteMenu;
