# Scoped Search to PatternFly Chips - Implementation Documentation

## Overview

This implementation provides bidirectional conversion between scoped search query strings and PatternFly Chip components, improving the user experience by providing visual representations of active search filters.

### Jira Issue
**SAT-39885**: [Proton] Use AI to write a React component that converts scoped search queries <> Patternfly chip

### MVP Scope
- Show chips on list pages using scoped search (All Hosts list, Hardware Models)
- Update the generic SearchBar component to display chips
- Bidirectional conversion between query strings and chips
- Documentation

## Architecture

### Components Created

1. **ScopedSearchParser.js** - Utility functions for parsing and converting search queries
2. **SearchChips.js** - React component for displaying filters as PatternFly chips
3. **Updated SearchBar/index.js** - Integration of chips into the existing SearchBar

### Data Flow

```
User Input (Search Query String)
          ↓
  parseScopedSearchQuery()
          ↓
  Array of Filter Objects
          ↓
    SearchChips Component
          ↓
  PatternFly Chip Display
          ↓
  User Removes Chip
          ↓
  removeFilterFromQuery()
          ↓
  Updated Search Query String
          ↓
  API Request with New Query
```

## Component Details

### 1. ScopedSearchParser.js

Located at: `webpack/assets/javascripts/react_app/components/SearchBar/ScopedSearchParser.js`

#### Purpose
Provides utility functions for parsing scoped search query strings and converting between query strings and filter objects.

#### Exported Functions

##### `parseScopedSearchQuery(queryString)`
Parses a scoped search query string into an array of filter objects.

**Parameters:**
- `queryString` (string): Scoped search query (e.g., "name = test and status != pending")

**Returns:**
- Array of filter objects: `[{ field, operator, value }, ...]`

**Example:**
```javascript
import { parseScopedSearchQuery } from './ScopedSearchParser';

const filters = parseScopedSearchQuery('name = prod and status != pending');
// Returns: [
//   { field: 'name', operator: '=', value: 'prod' },
//   { field: 'status', operator: '!=', value: 'pending' }
// ]
```

**Supported Operators:**
- `=` - equals
- `!=` - not equals
- `>` - greater than
- `<` - less than
- `>=` - greater than or equal
- `<=` - less than or equal
- `~` - contains (LIKE)
- `!~` - does not contain
- `^` - in list
- `!^` - not in list

**Supported Logical Operators:**
- `and` - logical AND (default when joining filters)
- `or` - logical OR
- `not` - logical NOT
- `has` - has field

##### `convertFiltersToQuery(filters)`
Converts an array of filter objects back to a scoped search query string.

**Parameters:**
- `filters` (Array): Array of filter objects

**Returns:**
- String: Scoped search query string

**Example:**
```javascript
import { convertFiltersToQuery } from './ScopedSearchParser';

const filters = [
  { field: 'name', operator: '=', value: 'test' },
  { field: 'status', operator: '!=', value: 'pending' }
];

const query = convertFiltersToQuery(filters);
// Returns: "name = test and status != pending"
```

##### `removeFilterFromQuery(queryString, filterToRemove)`
Removes a specific filter from a query string.

**Parameters:**
- `queryString` (string): Original query string
- `filterToRemove` (object): Filter object to remove

**Returns:**
- String: Updated query string without the removed filter

**Example:**
```javascript
import { removeFilterFromQuery } from './ScopedSearchParser';

const query = 'name = test and status = active';
const filterToRemove = { field: 'name', operator: '=', value: 'test' };

const newQuery = removeFilterFromQuery(query, filterToRemove);
// Returns: "status = active"
```

##### `addFilterToQuery(queryString, newFilter)`
Adds a new filter to an existing query string.

**Parameters:**
- `queryString` (string): Original query string
- `newFilter` (object): Filter object to add

**Returns:**
- String: Updated query string with the new filter

**Example:**
```javascript
import { addFilterToQuery } from './ScopedSearchParser';

const query = 'name = test';
const newFilter = { field: 'status', operator: '=', value: 'active' };

const newQuery = addFilterToQuery(query, newFilter);
// Returns: "name = test and status = active"
```

##### `updateFilterInQuery(queryString, oldFilter, newFilter)`
Updates an existing filter in a query string.

**Parameters:**
- `queryString` (string): Original query string
- `oldFilter` (object): Filter to replace
- `newFilter` (object): New filter (null to remove)

**Returns:**
- String: Updated query string

### 2. SearchChips.js

Located at: `webpack/assets/javascripts/react_app/components/SearchBar/SearchChips.js`

#### Purpose
Displays parsed search filters as PatternFly Chip components with remove functionality.

#### Props

| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `filters` | Array | No | `[]` | Array of filter objects to display |
| `onRemoveFilter` | Function | Yes | - | Callback when a chip is removed |
| `categoryName` | String | No | `'Active filters'` | Label for the chip group |

#### Filter Object Structure
```javascript
{
  field: string,      // Field name (e.g., 'name', 'status')
  operator: string,   // Operator (e.g., '=', '!=', '~')
  value: string       // Filter value
}
```

#### Example Usage
```javascript
import SearchChips from './SearchChips';

const filters = [
  { field: 'name', operator: '=', value: 'production' },
  { field: 'status', operator: '!=', value: 'pending' }
];

const handleRemove = (filter) => {
  console.log('Removed filter:', filter);
  // Update search query
};

<SearchChips
  filters={filters}
  onRemoveFilter={handleRemove}
  categoryName="Search Filters"
/>
```

#### Chip Display Format
Chips are displayed with friendly operator labels:
- `=` → `=`
- `!=` → `≠`
- `>=` → `≥`
- `<=` → `≤`
- `~` → `contains`
- `!~` → `not contains`
- `^` → `in`
- `!^` → `not in`

Example chip text: `name = production`, `status ≠ pending`

### 3. SearchBar Integration

Located at: `webpack/assets/javascripts/react_app/components/SearchBar/index.js`

#### Changes Made

1. **Import Statements Added:**
```javascript
import SearchChips from './SearchChips';
import {
  parseScopedSearchQuery,
  removeFilterFromQuery,
} from './ScopedSearchParser';
```

2. **Parsing Logic:**
```javascript
const filters = useMemo(() => parseScopedSearchQuery(search), [search]);
```

3. **Remove Handler:**
```javascript
const handleRemoveFilter = filterToRemove => {
  const newQuery = removeFilterFromQuery(search, filterToRemove);
  _onSearchChange(newQuery);
  if (onSearch) _onSearch(newQuery);
};
```

4. **Component Rendering:**
```jsx
<SearchChips filters={filters} onRemoveFilter={handleRemoveFilter} />
```

#### Updated Layout
The SearchBar now displays:
1. Search input with autocomplete (top)
2. Search chips below input (new)
3. Bookmarks dropdown (right side)

### 4. Styling Updates

Located at: `webpack/assets/javascripts/react_app/components/SearchBar/SearchBar.scss`

#### Changes Made

```scss
.foreman-search-bar {
  width: 100%;
  display: flex;
  flex-wrap: wrap;                              // Allow chips to wrap
  gap: var(--pf-v5-global--spacer--sm);        // Spacing between elements

  .search-chips-container {
    width: 100%;
    margin-top: var(--pf-v5-global--spacer--sm); // Space above chips
  }
}
```

## Testing

### Unit Tests

Test file: `ScopedSearchParser.test.js`

The parser has comprehensive test coverage including:
- Simple equality filters
- Multiple filters with AND/OR
- Quoted values
- All supported operators
- Edge cases (empty queries, mixed spacing)
- Round-trip conversion (parse → convert → parse)

To run tests:
```bash
npm test -- ScopedSearchParser.test.js
```

### Manual Testing

#### Test on Hosts Page
1. Navigate to **All Hosts** (`/hosts`)
2. Enter search query: `name = test`
3. Verify chip appears: `name = test`
4. Click the X on the chip
5. Verify chip is removed and search clears
6. Enter complex query: `name ~ prod and status = active`
7. Verify two chips appear
8. Remove one chip, verify query updates correctly

#### Test on Hardware Models Page
1. Navigate to **Hardware Models** (`/models`)
2. Enter search query: `vendor_class = Dell`
3. Verify chip appears
4. Test autocomplete integration
5. Verify chip updates when query changes

### Example Test Queries

Simple queries:
- `name = production`
- `status != pending`
- `count > 10`

Complex queries:
- `name ~ prod and status = active`
- `created >= "2024-01-01" and status != archived`
- `vendor_class = Dell and hardware_model ~ PowerEdge`

Quoted values:
- `name = "test server"`
- `description ~ "production environment"`

## Current Limitations

### 1. Read-Only Chips
Currently, chips can only be removed, not edited inline. To change a filter value, users must:
- Remove the chip
- Re-enter the search query with new values

**Future Enhancement:** Add inline editing or click-to-edit functionality.

### 2. Logical Operators Display
The current implementation joins all filters with `and` when converting back to query strings. While the parser recognizes `or`, `not`, and `has` operators, they are:
- Ignored during parsing (treated as separators)
- Not preserved in round-trip conversion
- Not visible in chip display

**Example:**
```
Input:  "name = test or name = prod"
Parsed: [{ field: 'name', operator: '=', value: 'test' },
         { field: 'name', operator: '=', value: 'prod' }]
Output: "name = test and name = prod"
```

**Future Enhancement:** Preserve logical operators and display them in chip groups.

### 3. No Grouping/Nesting Support
Complex queries with parentheses are not supported:
- `(name = test or name = prod) and status = active`

The parser will extract the filters but ignore the grouping.

**Future Enhancement:** Add support for nested filter groups with visual grouping in chips.

### 4. Value Type Inference
All values are treated as strings. The parser doesn't distinguish between:
- Numbers: `count > 10`
- Dates: `created >= "2024-01-01"`
- Booleans: `enabled = true`
- Strings: `name = "test"`

**Future Enhancement:** Add type inference and validation based on field definitions.

### 5. No Field Validation
The parser accepts any field name without validation against the model's scoped search configuration.

**Future Enhancement:** Integrate with backend field definitions to:
- Validate field names
- Provide field-specific operators
- Show available values for enumerated fields

## Integration Points

### Automatic Integration
The SearchChips component is automatically available on any page using:
- `TableIndexPage` component
- `SearchBar` component

This includes (but is not limited to):
- All Hosts (`/hosts`)
- Hardware Models (`/models`)
- Any other index pages using the generic table component

### No Additional Configuration Required
Pages using `TableIndexPage` or `SearchBar` will automatically get chip functionality without any code changes.

## Future Enhancements

### High Priority
1. **Inline Chip Editing**
   - Click chip to edit filter
   - Dropdown for operator selection
   - Type-ahead for values

2. **Field Autocomplete Integration**
   - Show available fields in autocomplete
   - Display field-specific operators
   - Suggest values for known fields

3. **Visual Logical Operators**
   - Show `and`/`or` between chips
   - Group related filters visually
   - Drag-and-drop to reorder

### Medium Priority
4. **Type-Aware Validation**
   - Date pickers for date fields
   - Number inputs for numeric fields
   - Dropdowns for enumerated values

5. **Saved Filter Sets**
   - Save common filter combinations
   - Quick-apply saved filters
   - Share filters with team

6. **Advanced Query Builder**
   - Visual query builder UI
   - Drag-and-drop filter creation
   - Nested condition support

### Low Priority
7. **Chip Keyboard Navigation**
   - Tab between chips
   - Delete key to remove
   - Arrow keys to navigate

8. **Export/Import Filters**
   - Copy filters as JSON
   - Share via URL parameters
   - Import from clipboard

## Performance Considerations

### Parsing Performance
The parser uses a single-pass algorithm with O(n) complexity where n is the query string length. Performance impact is negligible for typical query lengths (<1000 characters).

### Re-rendering Optimization
Uses `useMemo` to cache parsed filters and only re-parse when the search query changes.

### Large Filter Sets
Current implementation has no pagination or virtualization for chips. For queries with >20 filters, consider:
- Collapsible chip groups
- "Show more" functionality
- Virtual scrolling for chip containers

## Troubleshooting

### Chips Not Appearing
1. Check browser console for JavaScript errors
2. Verify search query is valid scoped search syntax
3. Ensure PatternFly CSS is loaded
4. Check that SearchBar is receiving the search prop

### Incorrect Parsing
1. Verify operator spacing in query
2. Check for special characters in values
3. Use quotes around values with spaces
4. Ensure logical operators are lowercase

### Styling Issues
1. Check PatternFly version compatibility (requires v5.4+)
2. Verify SCSS compilation
3. Check for CSS conflicts with custom styles
4. Inspect element classes match PatternFly naming

## Code Examples

### Custom Implementation (Outside TableIndexPage)

If you need to use SearchChips in a custom component:

```javascript
import React, { useState, useMemo } from 'react';
import SearchChips from '../SearchBar/SearchChips';
import {
  parseScopedSearchQuery,
  removeFilterFromQuery,
} from '../SearchBar/ScopedSearchParser';

const MyCustomSearch = () => {
  const [searchQuery, setSearchQuery] = useState('');

  const filters = useMemo(
    () => parseScopedSearchQuery(searchQuery),
    [searchQuery]
  );

  const handleRemoveFilter = filterToRemove => {
    const newQuery = removeFilterFromQuery(searchQuery, filterToRemove);
    setSearchQuery(newQuery);
  };

  return (
    <div>
      <input
        type="text"
        value={searchQuery}
        onChange={e => setSearchQuery(e.target.value)}
        placeholder="Enter search query..."
      />
      <SearchChips
        filters={filters}
        onRemoveFilter={handleRemoveFilter}
      />
    </div>
  );
};
```

### Adding Custom Chip Actions

To add custom actions beyond remove:

```javascript
import React from 'react';
import { Chip, ChipGroup } from '@patternfly/react-core';

const CustomSearchChips = ({ filters, onRemove, onEdit }) => (
  <ChipGroup categoryName="Filters">
    {filters.map((filter, index) => (
      <Chip
        key={index}
        onClick={() => onRemove(filter)}
        onAuxClick={() => onEdit(filter)}  // Custom action
      >
        {`${filter.field} ${filter.operator} ${filter.value}`}
      </Chip>
    ))}
  </ChipGroup>
);
```

## Conclusion

This implementation provides a solid foundation for visual search filter management using PatternFly chips. While there are opportunities for enhancement (inline editing, logical operator preservation, nested queries), the current MVP successfully achieves the goal of improving search UX on the All Hosts and Hardware Models pages.

The modular architecture makes it easy to extend functionality incrementally while maintaining backward compatibility with the existing text-based search interface.
