# SearchBar Component

## Overview

The SearchBar component provides search functionality with autocomplete and visual filter display using PatternFly chips.

## Features

- Text-based search input with autocomplete
- Visual representation of filters as PatternFly chips
- Bidirectional conversion between scoped search queries and chips
- Click to remove individual filters
- Bookmark support

## Quick Start

### Basic Usage

The SearchBar is already integrated into `TableIndexPage`, so any page using that component automatically gets chip functionality.

```javascript
import TableIndexPage from '../PF4/TableIndexPage/TableIndexPage';

<TableIndexPage
  apiUrl="/api/models"
  controller="models"
  header="Hardware Models"
/>
```

### Standalone Usage

```javascript
import SearchBar from '../SearchBar';

<SearchBar
  data={{
    autocomplete: {
      url: '/api/models/auto_complete_search',
      searchQuery: ''
    },
    controller: 'models'
  }}
  onSearch={(query) => console.log(query)}
/>
```

## Files

- `index.js` - Main SearchBar component
- `SearchAutocomplete.js` - Autocomplete input component
- `SearchChips.js` - Chip display component
- `ScopedSearchParser.js` - Query parsing utilities
- `AutoCompleteMenu.js` - Autocomplete dropdown menu
- `SearchBar.scss` - Component styles

## Documentation

For complete implementation details, see:
- **[SEARCH_CHIPS_IMPLEMENTATION.md](./SEARCH_CHIPS_IMPLEMENTATION.md)** - Full implementation guide

## Testing

```bash
npm test -- SearchBar.test.js
npm test -- ScopedSearchParser.test.js
```

## Examples

### Simple Search
```
name = production
```
Displays: [`name = production`]

### Multiple Filters
```
name ~ prod and status != pending
```
Displays: [`name contains prod`] [`status ≠ pending`]

### Quoted Values
```
description = "production environment"
```
Displays: [`description = production environment`]

## Supported Operators

- `=` equals
- `!=` not equals
- `>` greater than
- `<` less than
- `>=` greater than or equal
- `<=` less than or equal
- `~` contains
- `!~` not contains
- `^` in list
- `!^` not in list
