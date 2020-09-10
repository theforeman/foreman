/**
 * Modified PF4 ContextSelector
 *
 * Includes static group before the filter input and can show the filter input conditionally
 * Removed FocusTrap wrapper
 */
import React from 'react';
/* eslint-disable */
import styles from '@patternfly/react-styles/css/components/ContextSelector/context-selector';
import selectStyles from '@patternfly/react-styles/css/components/Select/select';
import { css } from '@patternfly/react-styles';
import SearchIcon from '@patternfly/react-icons/dist/js/icons/search-icon';
/* eslint-enable */
import PropTypes from 'prop-types';
import {
  ContextSelectorItem,
  Button,
  ButtonVariant,
  TextInput,
  InputGroup,
  Divider,
  KEY_CODES,
  Popper,
  FocusTrap,
} from '@patternfly/react-core';
import { ContextSelectorToggle } from '@patternfly/react-core/dist/js/components/ContextSelector/ContextSelectorToggle';
import { ContextSelectorMenuList } from '@patternfly/react-core/dist/js/components/ContextSelector/ContextSelectorMenuList';
import { ContextSelectorContext } from '@patternfly/react-core/dist/js/components/ContextSelector/contextSelectorConstants';

// seed for the aria-labelledby ID
let currentId = 0;
const newId = currentId++;

class CustomContextSelector extends React.Component {
  parentRef = React.createRef();

  onEnterPressed = event => {
    if (event.charCode === KEY_CODES.ENTER) {
      this.props.onSearchButtonClick();
    }
  };

  render() {
    const toggleId = `pf-context-selector-toggle-id-${newId}`;
    const screenReaderLabelId = `pf-context-selector-label-id-${newId}`;
    const searchButtonId = `pf-context-selector-search-button-id-${newId}`;
    const {
      children,
      className,
      isOpen,
      onToggle,
      onSelect,
      screenReaderLabel,
      toggleText,
      searchButtonAriaLabel,
      searchInputValue,
      onSearchInputChange,
      searchInputPlaceholder,
      onSearchButtonClick,
      menuAppendTo,
      showFilter,
      staticGroup,
      searchProps,
      ...props
    } = this.props;

    const nonFilterableGroup = (
      <div className={selectStyles.select}>
        <div className={selectStyles.selectMenuGroup}>
          <div className={selectStyles.selectMenuGroupTitle}>
            {staticGroup.title}
          </div>
          <ContextSelectorMenuList
            isOpen={isOpen}
            style={{ overflowY: 'hidden' }}
          >
            {staticGroup.items.map((item, i) => (
              <ContextSelectorItem key={i}>
                <a
                  href={item.href}
                  onClick={item.onClick}
                  style={{ textDecoration: 'inherit', color: 'inherit' }}
                  className={item.className}
                >
                  {item.title}
                </a>
              </ContextSelectorItem>
            ))}
          </ContextSelectorMenuList>
        </div>
        <Divider component="div" />
      </div>
    );

    const menuContainer = (
      <div className={css(styles.contextSelectorMenu)}>
        {isOpen && (
          <FocusTrap focusTrapOptions={{ clickOutsideDeactivates: true }}>
            {nonFilterableGroup}
            {showFilter && (
              <div className={css(styles.contextSelectorMenuSearch)}>
                <InputGroup>
                  <TextInput
                    value={searchInputValue}
                    type="search"
                    placeholder={searchInputPlaceholder}
                    onChange={onSearchInputChange}
                    onKeyPress={this.onEnterPressed}
                    aria-labelledby={searchButtonId}
                    {...searchProps}
                  />
                  <Button
                    variant={ButtonVariant.control}
                    aria-label={searchButtonAriaLabel}
                    id={searchButtonId}
                    onClick={onSearchButtonClick}
                  >
                    <SearchIcon aria-hidden="true" />
                  </Button>
                </InputGroup>
              </div>
            )}
            <ContextSelectorContext.Provider value={{ onSelect }}>
              <ContextSelectorMenuList isOpen={isOpen}>
                {children}
              </ContextSelectorMenuList>
            </ContextSelectorContext.Provider>
          </FocusTrap>
        )}
      </div>
    );
    const popperContainer = (
      <div
        className={css(
          styles.contextSelector,
          isOpen && styles.modifiers.expanded,
          className
        )}
        ref={this.parentRef}
        {...props}
      >
        {isOpen && menuContainer}
      </div>
    );
    const mainContainer = (
      <div
        className={css(
          styles.contextSelector,
          isOpen && styles.modifiers.expanded,
          className
        )}
        ref={this.parentRef}
        {...props}
      >
        {screenReaderLabel && (
          <span id={screenReaderLabelId} hidden>
            {screenReaderLabel}
          </span>
        )}
        <ContextSelectorToggle
          onToggle={onToggle}
          isOpen={isOpen}
          toggleText={toggleText}
          id={toggleId}
          parentRef={this.parentRef.current}
          aria-labelledby={`${screenReaderLabelId} ${toggleId}`}
        />
        {isOpen && menuAppendTo === 'inline' && menuContainer}
      </div>
    );
    const getParentElement = () => {
      if (this.parentRef && this.parentRef.current) {
        return this.parentRef.current.parentElement;
      }
      return null;
    };
    return menuAppendTo === 'inline' ? (
      mainContainer
    ) : (
      <Popper
        trigger={mainContainer}
        popper={popperContainer}
        appendTo={menuAppendTo === 'parent' ? getParentElement() : menuAppendTo}
        isVisible={isOpen}
      />
    );
  }
}
CustomContextSelector.propTypes = {
  /** content rendered inside the Context Selector */
  children: PropTypes.node,
  /** Classes applied to root element of Context Selector */
  className: PropTypes.string,
  /** Flag to indicate if Context Selector is opened */
  isOpen: PropTypes.bool,
  /** Function callback called when user clicks toggle button */
  onToggle: PropTypes.func,
  /** Function callback called when user selects item */
  onSelect: PropTypes.func,
  /** Labels the Context Selector for Screen Readers */
  screenReaderLabel: PropTypes.string,
  /** Text that appears in the Context Selector Toggle */
  toggleText: PropTypes.string,
  /** Aria-label for the Context Selector Search Button */
  searchButtonAriaLabel: PropTypes.string,
  /** Value in the Search field */
  searchInputValue: PropTypes.string,
  /** Function callback called when user changes the Search Input */
  onSearchInputChange: PropTypes.func,
  /** Search Input placeholder */
  searchInputPlaceholder: PropTypes.string,
  /** Function callback for when Search Button is clicked */
  onSearchButtonClick: PropTypes.func,
  /** True to show the search filter */
  showFilter: PropTypes.bool,
  /** Items that are inserted before the search filter */
  staticGroup: PropTypes.any,
  /** Additional props passed to the search filter */
  searchProps: PropTypes.any,
  /** Should the dropdown be appended 'inline' or to the 'parent' */
  menuAppendTo: PropTypes.string,
};
CustomContextSelector.defaultProps = {
  children: null,
  className: '',
  isOpen: false,
  onToggle: () => undefined,
  onSelect: () => undefined,
  screenReaderLabel: '',
  toggleText: '',
  searchButtonAriaLabel: 'Search menu items',
  searchInputValue: '',
  onSearchInputChange: () => undefined,
  searchInputPlaceholder: 'Search',
  onSearchButtonClick: () => undefined,
  showFilter: true,
  staticGroup: null,
  searchProps: null,
  menuAppendTo: 'inline',
};
export default CustomContextSelector;
