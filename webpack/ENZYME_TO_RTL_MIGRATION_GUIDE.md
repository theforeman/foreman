# Enzyme Snapshot Tests to React Testing Library Migration Guide

## Overview

This guide documents the migration process from Enzyme snapshot tests to React Testing Library (RTL) tests in the Foreman webpack codebase. The migration focuses on testing user-visible behavior and interactions rather than implementation details.

## Migration Progress

### ✅ Completed Migrations

#### **Core Components (13 files migrated)**
- **Form.test.js** - Error display, form structure, and user interactions
- **MessageBox.test.js** - Message display and icon rendering
- **SearchInput.test.js** - User input, focus behavior, and search interactions
- **ShortDateTime.test.js** - Date formatting, i18n integration, and timezone handling
- **RelativeDateTime.test.js** - Relative time formatting and i18n integration
- **IsoDate.test.js** - ISO date formatting and timezone handling
- **Loader.test.js** - Loading states and conditional rendering
- **AlertBody.test.js** - Alert content, links, and children rendering
- **BarChart.test.js** - Chart rendering, data handling, and service integration
- **DonutChart.test.js** - Chart visualization, tooltips, and accessibility
- **Actions.test.js** - Form buttons, disabled states, and user interactions
- **CommonForm.test.js** - Form validation, labels, and error handling
- **ModalProgressBar.test.js** - Modal display, progress tracking, and accessibility

### 📁 Created Files
- **testHelpers.js** - Common testing utilities and helper functions

## Key Migration Principles

### 1. **From Structure to Behavior**
```javascript
// ❌ Before (Enzyme Snapshot)
const wrapper = shallow(<Form error={errorProps} />);
expect(wrapper).toMatchSnapshot();

// ✅ After (RTL Behavior)
render(<Form error={errorProps} />);
expect(screen.getByRole('alert')).toBeInTheDocument();
expect(screen.getByText('error message')).toBeInTheDocument();
```

### 2. **From Implementation to User Experience**
```javascript
// ❌ Before (Testing internal structure)
expect(wrapper.find('.pficon-info')).toHaveLength(1);

// ✅ After (Testing user-visible content)
const container = screen.getByText('message').closest('div');
const icon = container.querySelector('.pficon-info');
expect(icon).toHaveClass('pficon', 'pficon-info');
```

### 3. **From Static to Interactive**
```javascript
// ❌ Before (Static snapshot)
const wrapper = shallow(<SearchInput searchValue="test" />);
expect(wrapper).toMatchSnapshot();

// ✅ After (Interactive behavior)
render(<SearchInput searchValue="test" />);
const searchInput = screen.getByRole('searchbox');
fireEvent.change(searchInput, { target: { value: 'new value' } });
expect(searchInput).toHaveValue('new value');
```

## Testing Utilities

### Core Helpers (`testHelpers.js`)

#### **renderWithStore(component, initialState)**
For components requiring Redux store:
```javascript
const { store } = renderWithStore(<MyComponent />, { user: { name: 'John' } });
```

#### **renderWithI18n(component, mockDate, timezone)**
For components with internationalization:
```javascript
renderWithI18n(<DateComponent date={date} />, new Date(), 'UTC');
```

#### **renderWithStoreAndI18n(component, initialState, mockDate, timezone)**
For components needing both Redux and i18n:
```javascript
renderWithStoreAndI18n(<ComplexComponent />, { data: [] }, new Date(), 'UTC');
```

### Assertion Helpers

#### **formAssertions**
- `expectErrorAlert(screen, errorText)` - Test error display
- `expectErrorList(screen, errorMessages)` - Test multiple errors
- `expectWarningAlert(screen, warningText)` - Test warning display

#### **tableAssertions**
- `expectColumnHeaders(screen, columnNames)` - Test table headers
- `expectRowData(screen, rowData)` - Test table content
- `expectSortableColumn(screen, columnName)` - Test sorting functionality

#### **dateTimeAssertions**
- `expectFormattedDate(screen, expectedFormat)` - Test date formatting
- `expectDefaultValue(screen, defaultValue)` - Test fallback values

### Mock Creators

#### **createMockProps**
```javascript
const errorProps = createMockProps.formError(['Error message'], 'danger');
const tableProps = createMockProps.tableData(columns, results);
const dateProps = createMockProps.dateTimeProps(new Date());
```

## Migration Patterns by Component Type

### 1. **Form Components**

**Focus Areas:**
- Error message display and accessibility
- Form submission handling
- Input validation feedback
- Button states (disabled, loading)

**Example Pattern:**
```javascript
it('displays validation errors to user', () => {
  const errorProps = createMockProps.formError(['Required field'], 'danger');
  render(<FormComponent {...errorProps} />);

  formAssertions.expectErrorAlert(screen, 'Required field');
  expect(screen.getByRole('alert')).toBeInTheDocument();
});
```

### 2. **Interactive Components**

**Focus Areas:**
- User input handling
- Keyboard navigation
- Focus management
- Event callbacks

**Example Pattern:**
```javascript
it('handles user interactions', async () => {
  const onSubmit = jest.fn();
  render(<InteractiveComponent onSubmit={onSubmit} />);

  const button = screen.getByRole('button', { name: /submit/i });
  fireEvent.click(button);

  await waitFor(() => {
    expect(onSubmit).toHaveBeenCalled();
  });
});
```

### 3. **Display Components**

**Focus Areas:**
- Content rendering
- Conditional display
- Icon and styling verification
- Accessibility attributes

**Example Pattern:**
```javascript
it('displays content with proper styling', () => {
  render(<DisplayComponent message="Hello" type="info" />);

  expect(screen.getByText('Hello')).toBeInTheDocument();

  const container = screen.getByText('Hello').closest('div');
  const icon = container.querySelector('.icon-info');
  expect(icon).toHaveClass('icon', 'icon-info');
});
```

### 4. **Async/I18n Components**

**Focus Areas:**
- Async data loading
- Internationalization
- Date/time formatting
- Error states

**Example Pattern:**
```javascript
it('formats dates with i18n', async () => {
  renderWithI18n(<DateComponent date={testDate} />, mockNow, 'UTC');

  await waitFor(async () => {
    await intl.ready;
  });

  expect(screen.getByText(/2017|Oct|13/)).toBeInTheDocument();
});
```

## Step-by-Step Migration Process

### For Each Test File:

1. **Analyze Current Tests**
   - Identify what the snapshots are actually testing
   - Determine user-facing behaviors
   - Note any interactive elements

2. **Update Imports**
   ```javascript
   // Remove
   import { shallow, mount } from 'enzyme';

   // Add
   import { render, screen, fireEvent, waitFor } from '@testing-library/react';
   import '@testing-library/jest-dom';
   import { renderWithStore, formAssertions } from '../../../common/testHelpers';
   ```

3. **Convert Test Structure**
   ```javascript
   // Before
   const wrapper = shallow(<Component prop="value" />);
   expect(wrapper).toMatchSnapshot();

   // After
   render(<Component prop="value" />);
   expect(screen.getByText('expected content')).toBeInTheDocument();
   ```

4. **Add Behavioral Tests**
   - Test user interactions (clicks, typing, form submission)
   - Test accessibility (roles, labels, keyboard navigation)
   - Test error states and edge cases
   - Test async behavior where applicable

5. **Clean Up**
   - Remove snapshot files
   - Update test descriptions to reflect behavior being tested
   - Add additional test cases for edge cases

## Common Patterns and Solutions

### Testing Icons and Styling
```javascript
// Use querySelector for non-semantic elements like icons
const container = screen.getByText('message').closest('div');
const icon = container.querySelector('.pficon-info');
expect(icon).toHaveClass('pficon', 'pficon-info');
```

### Testing Async Operations
```javascript
// Use waitFor for async operations
await waitFor(async () => {
  await intl.ready;
});

// Or for callbacks
await waitFor(() => {
  expect(mockCallback).toHaveBeenCalled();
}, { timeout: 1000 });
```

### Testing Form Interactions
```javascript
// Test form submission
const form = screen.getByRole('form');
fireEvent.submit(form);

// Test input changes
const input = screen.getByRole('textbox');
fireEvent.change(input, { target: { value: 'new value' } });
expect(input).toHaveValue('new value');
```

### Testing Conditional Rendering
```javascript
// Test presence/absence of elements
expect(screen.getByText('visible text')).toBeInTheDocument();
expect(screen.queryByText('hidden text')).not.toBeInTheDocument();

// Test element counts
expect(screen.getAllByRole('listitem')).toHaveLength(3);
```

## Benefits of Migration

### ✅ Improved Test Quality
- Tests break only when user-facing behavior changes
- Better coverage of accessibility concerns
- More realistic user interaction testing

### ✅ Maintenance Benefits
- Tests are less brittle to markup changes
- Clearer test intent and purpose
- Better debugging when tests fail

### ✅ Developer Experience
- Faster test execution
- More meaningful test failures
- Better alignment with user expectations

## Next Steps

### Recommended Migration Order:
1. **Simple display components** (similar to MessageBox)
2. **Form components** (similar to Form)
3. **Interactive components** (similar to SearchInput)
4. **Complex async components** (similar to ShortDateTime)
5. **Integration tests** that combine multiple components

### Files Ready for Migration:
Based on the snapshot analysis, prioritize these component types:
- Date/Time components (`DateTimePicker`, `RelativeDateTime`, etc.)
- Chart components (`BarChart`, `DonutChart`, `LineChart`)
- Table components (`TableSelectionCell`, `SortableHeader`)
- Form components (`CommonForm`, `CounterInput`, `OrderableSelect`)

## Testing Commands

```bash
# Run specific test file
npm test -- Form.test.js

# Run tests in watch mode
npm test -- --watch

# Run tests with coverage
npm test -- --coverage

# Run all migrated tests
npm test -- --testPathPattern="Form\.test\.js|MessageBox\.test\.js|SearchInput\.test\.js|ShortDateTime\.test\.js"
```

## Resources

- [React Testing Library Documentation](https://testing-library.com/docs/react-testing-library/intro)
- [Jest DOM Matchers](https://github.com/testing-library/jest-dom)
- [Common Testing Patterns](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
- [Accessibility Testing](https://testing-library.com/docs/guide-which-query)

---

**Migration Status:** 13/170+ test files migrated (7.6% complete)
**Snapshot Files Removed:** 13 files deleted
**Next Priority:** DateTimePicker components, Table components, Complex forms
**Estimated Remaining Effort:** ~2-3 weeks with 5-10 files per day

### 🎯 **Migration Categories Completed**
- ✅ **Date/Time Components** - All basic date formatting components migrated
- ✅ **Chart Components** - Bar and Donut charts with service integration
- ✅ **Form Components** - Core form elements, validation, and interactions
- ✅ **UI Components** - Loaders, alerts, modals, and progress indicators
- 🔄 **Complex Components** - DateTimePicker suite (10+ components remaining)
- ⏳ **Table Components** - Interactive tables and selection components
- ⏳ **Integration Tests** - Multi-component workflows
