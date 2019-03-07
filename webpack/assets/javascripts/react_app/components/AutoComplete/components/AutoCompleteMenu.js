import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { groupBy } from 'lodash';
import { TypeAheadSelect } from 'patternfly-react';
import SubstringWrapper from '../../common/SubstringWrapper';

const { Menu, MenuItem } = TypeAheadSelect;
const { Divider, Header } = Menu;

const AutoCompleteMenu = ({ results, menuProps }) => {
  if (results && results.length === 0) {
    return null;
  }

  let itemIndex = 0;
  const grouped = groupBy(results, r => r.category);
  const getMenuItemsByCategory = category =>
    grouped[category].map(result => {
      const item = (
        <MenuItem key={itemIndex} option={result.label} position={itemIndex}>
          <SubstringWrapper substring={menuProps.text}>
            {result.label}
          </SubstringWrapper>
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
        <Header key={`${category}-header`}>{category}</Header>
        {getMenuItemsByCategory(category)}
      </Fragment>
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
