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
      'disableHTMLAutocomplete',
      'handleKeyDown',
    ]);
    this._typeahead = React.createRef();
    debounceMethods(this, 500, ['handleLoading']);
  }

  componentDidMount() {
    window.addEventListener('keypress', this.windowKeyPressHandler);
    const {
      controller,
      initialQuery: searchQuery,
      initialUrl: url,
      initialDisabled: isDisabled,
      initialError: error,
      id,
      initialUpdate,
    } = this.props;
    initialUpdate({
      searchQuery,
      controller,
      url,
      isDisabled,
      id,
      error,
    });
    this.disableHTMLAutocomplete();
  }

  componentDidUpdate({ trigger: prevTrigger }) {
    const { trigger } = this.props;
    if (trigger !== prevTrigger && trigger === TRIGGERS.RESET) {
      /** eslint-disable-next-line  react/prop-types */
      this._typeahead.current.getInstance().clear();
    }
  }

  windowKeyPressHandler(e) {
    if (!this.props.useKeyShortcuts) {
      return;
    }
    const instance = this._typeahead.current.getInstance();
    switch (e.charCode) {
      case KEYCODES.ENTER: {
        this.props.handleSearch();
        break;
      }
      case KEYCODES.FWD_SLASH:
      case KEYCODES.BACK_SLASH: {
        if (!instance.state.showMenu) {
          e.preventDefault();
          instance.focus();
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
  disableHTMLAutocomplete() {
    const input =
      this._typeahead.current &&
      this._typeahead.current.getInstance().getInput();
    if (input) {
      input.autocomplete = 'off';
    }
  }

  getResults(searchQuery, trigger) {
    const { getResults, controller, url, id } = this.props;
    getResults({
      url,
      searchQuery,
      controller,
      trigger,
      id,
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
    const { resetData, controller, id } = this.props;
    resetData({ controller, id });
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
      id,
      isDisabled,
    } = this.props;
    /** Using a 3rd party library (react-bootstrap-typeahead) that expects a mutable array. */
    const options = Immutable.isImmutable(results)
      ? results.asMutable()
      : results;
    return (
      <div className="foreman-autocomplete">
        <TypeAheadSelect
          {...this.props}
          ref={this._typeahead}
          defaultInputValue={initialQuery}
          options={options}
          isLoading={this.handleLoading()}
          onInputChange={this.handleInputChange}
          onChange={this.handleResultsChange}
          onFocus={this.handleInputFocus}
          onKeyDown={this.handleKeyDown}
          emptyLabel={emptyLabel}
          placeholder={__(placeholder)}
          renderMenu={(r, menuProps) => (
            <AutoCompleteMenu {...{ results: r, menuProps }} />
          )}
          disabled={isDisabled}
          inputProps={{
            className: classNames(
              'search-input',
              useKeyShortcuts ? 'use-shortcuts' : ''
            ),
            spellCheck: 'false',
            'data-autocomplete-id': id,
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
  results: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string,
      controller: PropTypes.string,
    })
  ),
  searchQuery: PropTypes.string,
  initialQuery: PropTypes.string,
  inputProps: PropTypes.object,
  status: PropTypes.string,
  error: PropTypes.string,
  initialError: PropTypes.string,
  controller: PropTypes.string,
  getResults: PropTypes.func,
  resetData: PropTypes.func,
  initialUpdate: PropTypes.func,
  useKeyShortcuts: PropTypes.bool,
  placeholder: PropTypes.string,
  emptyLabel: PropTypes.string,
  url: PropTypes.string,
  initialUrl: PropTypes.string,
  handleSearch: PropTypes.func,
  isDisabled: PropTypes.bool,
  initialDisabled: PropTypes.bool,
  id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  trigger: PropTypes.string,
};

AutoComplete.defaultProps = {
  results: [],
  searchQuery: '',
  initialQuery: '',
  inputProps: {},
  status: null,
  error: null,
  initialError: null,
  controller: null,
  getResults: noop,
  resetData: noop,
  initialUpdate: noop,
  useKeyShortcuts: true,
  placeholder: __('Filter ...'),
  emptyLabel: null,
  url: null,
  initialUrl: null,
  handleSearch: noop,
  isDisabled: false,
  initialDisabled: false,
  id: null,
  trigger: null,
};

AutoComplete.SearchButton = AutoCompleteSearchButton;
AutoComplete.Error = AutoCompleteError;

export default AutoComplete;
