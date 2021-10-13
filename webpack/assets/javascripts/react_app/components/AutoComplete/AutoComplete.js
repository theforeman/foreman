import React from 'react';
import PropTypes from 'prop-types';
import { TypeAheadSelect } from 'patternfly-react';
import classNames from 'classnames';
import Immutable from 'seamless-immutable';
import { bindMethods, debounceMethods, noop } from '../../common/helpers';
import AutoCompleteMenu from './components/AutoCompleteMenu';
import AutoCompleteError from './components/AutoCompleteError';
import AutoCompleteAux from './components/AutoCompleteAux';
import AutoCompleteFocusShortcut from './components/AutoCompleteFocusShortcut';
import { STATUS } from '../../constants';
import { TRIGGERS } from './AutoCompleteConstants';
import { KEYCODES } from '../../common/keyCodes';
import { translate as __ } from '../../common/I18n';
import './auto-complete.scss';

class AutoComplete extends React.Component {
  constructor(props) {
    super(props);
    bindMethods(this, [
      'handleClear',
      'handleInputChange',
      'handleResultsChange',
      'handleInputFocus',
      'getResults',
      'windowKeyPressHandler',
      'handleKeyDown',
    ]);
    this._typeahead = React.createRef();
    debounceMethods(this, 500, ['handleLoading']);
  }

  componentDidMount() {
    window.addEventListener('keypress', this.windowKeyPressHandler);
    const { controller, searchQuery, disabled, error, id, url, initialUpdate } =
      this.props;

    initialUpdate({ searchQuery, controller, id, disabled, error, url });
  }

  componentDidUpdate(prevProps) {
    this.handleLoading();
    const { searchQuery, trigger } = this.props;
    const { RESET, CONTROLLER_CHANGED } = TRIGGERS;
    if (trigger === RESET || trigger === CONTROLLER_CHANGED) {
      this.handleClear();
    }
    if (prevProps.searchQuery !== searchQuery) {
      const typeahead = this._typeahead && this._typeahead.current;
      typeahead && typeahead.setState({ text: searchQuery });
    }
  }

  windowKeyPressHandler(e) {
    const { useKeyShortcuts, handleSearch } = this.props;
    const instance = this._typeahead.current.getInstance();
    const { ENTER, FWD_SLASH, BACK_SLASH } = KEYCODES;
    const { tagName } = e.target;
    const didEventCameFromInput = tagName === 'INPUT' || tagName === 'TEXTAREA';

    /**
     Disable this functionality if the event came from an input,
     or if the 'useKeyShortcuts' is falsy.
    */
    if (didEventCameFromInput || !useKeyShortcuts) {
      return;
    }

    switch (e.charCode) {
      case ENTER: {
        handleSearch();
        break;
      }
      case FWD_SLASH:
      case BACK_SLASH: {
        const {
          focus,
          state: { showMenu },
        } = instance;
        const isMenuHidden = !showMenu;
        if (isMenuHidden) {
          e.preventDefault();
          focus();
        }
        break;
      }
      default: {
        break;
      }
    }
  }

  getResults(searchQuery, trigger, id) {
    const { getResults, controller, url } = this.props;
    getResults({
      url,
      searchQuery,
      controller,
      trigger,
      id,
    });
  }

  handleInputFocus({ target: { value } }) {
    const { id, results } = this.props;
    if (results.length === 0) {
      this.getResults(value, TRIGGERS.INPUT_FOCUS, id);
    }
  }

  handleInputChange(searchQuery) {
    const { id } = this.props;
    this.getResults(searchQuery, TRIGGERS.INPUT_CHANGE, id);
  }

  // Gets the first result from an array of selected results.
  handleResultsChange({ 0: result }) {
    const { id } = this.props;
    if (!result) {
      return;
    }
    this.getResults(result, TRIGGERS.ITEM_SELECT, id);
    /**
     *  HACK: I had no choice but to call to an inner function,
     * due to lack of design in react-bootstrap-typeahead.
     */
    this._typeahead.current.getInstance()._showMenu();
  }

  handleKeyDown({ keyCode }) {
    const instance = this._typeahead.current.getInstance();
    switch (keyCode) {
      case KEYCODES.ENTER: {
        if (!instance.state.activeItem) {
          this.props.handleSearch();
        }
        break;
      }
      case KEYCODES.ESC: {
        instance.blur();
        break;
      }
      default: {
        break;
      }
    }
  }

  handleClear() {
    const { id } = this.props;
    this._typeahead.current.getInstance().clear();
    this.getResults('', TRIGGERS.INPUT_CLEAR, id);
  }

  handleLoading() {
    const { status } = this.props;
    const typeahead = this._typeahead && this._typeahead.current;
    const isLoading = status === STATUS.PENDING;
    typeahead && typeahead.setState({ isLoading });
  }

  componentWillUnmount() {
    window.removeEventListener('keypress', this.windowKeyPressHandler);
    const { resetData, controller, id } = this.props;
    resetData(controller, id);
  }

  render() {
    const {
      id,
      error,
      name,
      value,
      searchQuery,
      inputProps,
      placeholder,
      results,
      useKeyShortcuts,
      disabled,
    } = this.props;
    /** Using a 3rd party library (react-bootstrap-typeahead) that expects a mutable array. */
    const options = Immutable.isImmutable(results)
      ? results.asMutable()
      : results;

    return (
      <div className="foreman-autocomplete">
        <TypeAheadSelect
          id={id}
          ref={this._typeahead}
          defaultInputValue={value || searchQuery}
          options={options}
          onInputChange={this.handleInputChange}
          onChange={this.handleResultsChange}
          onFocus={this.handleInputFocus}
          onKeyDown={this.handleKeyDown}
          placeholder={placeholder}
          disabled={disabled}
          renderMenu={(r, menuProps) => (
            <AutoCompleteMenu {...{ results: r, menuProps }} />
          )}
          inputProps={{
            className: classNames(
              'search-input',
              useKeyShortcuts ? 'use-shortcuts' : ''
            ),
            spellCheck: 'false',
            'data-autocomplete-id': id,
            autoComplete: 'off',
            name,
            ...inputProps,
          }}
        />
        {searchQuery && <AutoCompleteAux onClear={this.handleClear} />}
        <AutoCompleteFocusShortcut useKeyShortcuts={useKeyShortcuts} />
        <AutoCompleteError error={error} />
      </div>
    );
  }
}

AutoComplete.propTypes = {
  id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  url: PropTypes.string.isRequired,
  name: PropTypes.string,
  value: PropTypes.string,
  results: PropTypes.array,
  searchQuery: PropTypes.string,
  inputProps: PropTypes.object,
  status: PropTypes.string,
  error: PropTypes.string,
  initialError: PropTypes.string,
  controller: PropTypes.string,
  handleSearch: PropTypes.func,
  getResults: PropTypes.func,
  resetData: PropTypes.func,
  initialUpdate: PropTypes.func,
  useKeyShortcuts: PropTypes.bool,
  placeholder: PropTypes.string,
  disabled: PropTypes.bool,
  trigger: PropTypes.string,
};

AutoComplete.defaultProps = {
  name: null,
  value: null,
  results: [],
  searchQuery: '',
  inputProps: {},
  status: null,
  error: null,
  initialError: null,
  controller: null,
  handleSearch: noop,
  getResults: noop,
  resetData: noop,
  initialUpdate: noop,
  useKeyShortcuts: false,
  placeholder: __('Search'),
  disabled: false,
  trigger: null,
};

AutoComplete.Error = AutoCompleteError;

export default AutoComplete;
