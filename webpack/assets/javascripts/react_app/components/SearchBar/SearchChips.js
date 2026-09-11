import React from 'react';
import PropTypes from 'prop-types';
import { Chip, ChipGroup } from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';
import './SearchBar.scss';

const getOperatorLabel = operator => {
  const operatorLabels = {
    '=': '=',
    '!=': '≠',
    '>': '>',
    '<': '<',
    '>=': '≥',
    '<=': '≤',
    '~': __('contains'),
    '!~': __('not contains'),
    '^': __('in'),
    '!^': __('not in'),
  };
  return operatorLabels[operator] || operator;
};

export const SearchChips = ({ filters, onRemoveFilter, categoryName }) => {
  if (!filters || filters.length === 0) {
    return null;
  }

  const handleRemove = (_event, filter) => {
    onRemoveFilter(filter);
  };

  return (
    <div className="search-chips-container">
      <ChipGroup
        categoryName={categoryName || __('Active filters')}
        ouiaId="search-chips-group"
      >
        {filters.map((filter, index) => {
          const chipText = `${filter.field} ${getOperatorLabel(
            filter.operator
          )} ${filter.value}`;
          return (
            <Chip
              key={`${filter.field}-${filter.operator}-${filter.value}-${index}`}
              onClick={() => handleRemove(null, filter)}
              ouiaId={`search-chip-${filter.field}`}
            >
              {chipText}
            </Chip>
          );
        })}
      </ChipGroup>
    </div>
  );
};

SearchChips.propTypes = {
  filters: PropTypes.arrayOf(
    PropTypes.shape({
      field: PropTypes.string.isRequired,
      operator: PropTypes.string.isRequired,
      value: PropTypes.string.isRequired,
    })
  ),
  onRemoveFilter: PropTypes.func.isRequired,
  categoryName: PropTypes.string,
};

SearchChips.defaultProps = {
  filters: [],
  categoryName: null,
};

export default SearchChips;
