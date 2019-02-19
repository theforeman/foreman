import React from 'react';
import PropTypes from 'prop-types';
import { TypeAheadSelect } from 'patternfly-react';
import classNames from 'classnames';
import Immutable from 'seamless-immutable';
import { bindMethods, debounceMethods, noop } from '../../common/helpers';
import AutoCompleteMenu from './components/AutoCompleteMenu';
import AutoCompleteSearchButton from './components/AutoCompleteSearchButton';
import AutoCompleteError from './components/AutoCompleteError';
import AutoCompleteAux from './components/AutoCompleteAux';
import AutoCompleteFocusShortcut from './components/AutoCompleteFocusShortcut';
import { STATUS } from '../../constants';
import { TRIGGERS, KEYCODES } from './AutoCompleteConstants';
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
      'unableHTMLAutocomplete',
      'handleKeyDown',
    ]);
    this._typeahead = React.createRef();
    debounceMethods(this, 500, ['handleLoading']);
  }

  componentDidMount() {
    window.addEventListener('keypress', this.windowKeyPressHandler);
    const { controller, initialQuery, initialUpdate } = this.props;
    initialUpdate(initialQuery, controller);
    this.unableHTMLAutocomplete();
  }

  componentDidUpdate(prevProps) {
    const { initialQuery } = this.props;
    if (prevProps.initialQuery !== initialQuery)
      this._typeahead.current.getInstance().setState({ text: initialQuery });
  }

  windowKeyPressHandler(e) {
    const { useKeyShortcuts, handleSearch } = this.props;
    const instance = this._typeahead.current.getInstance();
    const { ENTER, FWD_SLASH, BACK_SLASH } = KEYCODES;
    const didEventCameFromInput = e.target.tagName === 'INPUT';

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

  // TODO: remove this HACK when react-bootstrap-typeahead
  // will support autocomplete = 'off' instead of 'nope' in inputProps prop.
  unableHTMLAutocomplete() {
    const input =
      this._typeahead.current &&
      this._typeahead.current.getInstance().getInput();
    if (input) {
      input.autocomplete = 'off';
    }
  }

  getResults(searchQuery, trigger) {
    const { getResults, controller, url } = this.props;
    getResults({
      url,
      searchQuery,
      controller,
      trigger,
    });
  }

  handleInputFocus({ target: { value } }) {
    if (this.props.results.length === 0) {
      this.getResults(value, TRIGGERS.INPUT_FOCUS);
    }
  }

  handleInputChange(query) {
    this.getResults(query, TRIGGERS.INPUT_CHANGE);
  }

  // Gets the first result from an array of selected results.
  handleResultsChange({ 0: result }) {
    if (!result) {
      return;
    }
    this.getResults(result, TRIGGERS.ITEM_SELECT);
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
    this._typeahead.current.getInstance().clear();
    this.getResults('', TRIGGERS.INPUT_CLEAR);
  }

  handleLoading() {
    return this.props.status === STATUS.PENDING;
  }

  componentWillUnmount() {
    window.removeEventListener('keypress', this.windowKeyPressHandler);
    const { resetData, controller } = this.props;
    resetData(controller);
  }

  render() {
    const {
      emptyLabel,
      error,
      initialQuery,
      inputProps,
      placeholder,
      results,
      useKeyShortcuts,
      showLoading,
    } = this.props;

    /** Using a 3rd party library (react-bootstrap-typeahead) that expects a mutable array. */
    const options = Immutable.isImmutable(results)
      ? results.asMutable()
      : results;
    return (
      <div>
        <TypeAheadSelect
          ref={this._typeahead}
          defaultInputValue={initialQuery}
          options={options}
          isLoading={this.handleLoading() || showLoading}
          onInputChange={this.handleInputChange}
          onChange={this.handleResultsChange}
          onFocus={this.handleInputFocus}
          onKeyDown={this.handleKeyDown}
          emptyLabel={emptyLabel}
          placeholder={__(placeholder)}
          renderMenu={(r, menuProps) => (
            <AutoCompleteMenu {...{ results: r, menuProps }} />
          )}
          inputProps={{
            className: classNames(
              'search-input',
              useKeyShortcuts ? 'use-shortcuts' : ''
            ),
            spellCheck: 'false',
            ...inputProps,
          }}
        />
        <AutoCompleteAux onClear={this.handleClear} />
        <AutoCompleteFocusShortcut useKeyShortcuts={useKeyShortcuts} />
        <AutoCompleteError error={error} />
      </div>
    );
  }
}

AutoComplete.propTypes = {
  results: PropTypes.array,
  searchQuery: PropTypes.string,
  initialQuery: PropTypes.string,
  inputProps: PropTypes.object,
  status: PropTypes.string,
  error: PropTypes.string,
  controller: PropTypes.string,
  handleSearch: PropTypes.func,
  getResults: PropTypes.func,
  resetData: PropTypes.func,
  initialUpdate: PropTypes.func,
  useKeyShortcuts: PropTypes.bool,
  placeholder: PropTypes.string,
  emptyLabel: PropTypes.string,
  url: PropTypes.string,
  showLoading: PropTypes.bool,
};

AutoComplete.defaultProps = {
  results: [],
  searchQuery: '',
  initialQuery: '',
  inputProps: {},
  status: null,
  error: null,
  controller: null,
  handleSearch: noop,
  getResults: noop,
  resetData: noop,
  initialUpdate: noop,
  useKeyShortcuts: true,
  placeholder: 'Filter ...',
  emptyLabel: null,
  url: null,
  showLoading: false,
};

AutoComplete.SearchButton = AutoCompleteSearchButton;
AutoComplete.Error = AutoCompleteError;

export default AutoComplete;
