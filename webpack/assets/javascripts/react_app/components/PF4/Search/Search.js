/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import { ControlLabel } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../common/I18n';
import TypeAhead from '../TypeAhead';
import api from '../../../redux/API/API';
import { stringIncludes } from './helpers';

class Search extends Component {
  constructor(props) {
    super(props);
    this.state = { items: [], typingTimeout: 0 };
  }

  componentDidMount() {
    this.onInputUpdate();
  }

  onInputUpdate = async (searchTerm = '') => {
    // update autoSearchEnabled to use real setting
    const {
      getAutoCompleteParams,
      settings: { autoSearchEnabled },
    } = this.props;
    const items = this.state.items.filter(({ text }) =>
      stringIncludes(text, searchTerm)
    );

    if (items.length !== this.state.items.length) {
      this.setState({ items });
    }

    const params = getAutoCompleteParams(searchTerm);
    const autoCompleteParams = [
      params.endpoint,
      params.headers || {},
      params.params || {},
    ];

    if (autoCompleteParams[0] !== '') {
      const { data } = await api.get(...autoCompleteParams);
      this.setState({
        items: data
          .filter(({ error }) => !error)
          .map(({ label }) => ({
            text: label.trim(),
          })),
      });
    }

    if (autoSearchEnabled && searchTerm.length > 0) {
      this.autoSearch(searchTerm);
    }
  };

  onSearch = search => {
    if (this.props.updateSearchQuery) this.props.updateSearchQuery(search);
    this.props.onSearch(search);
  };

  // Continually clear and set the timeout as the user types. When the typing pauses, perform the
  // search. This allows us to not overload the server by requesting on each keystroke.
  autoSearch(searchTerm) {
    const {
      settings: { autoSearchDelay },
    } = this.props;
    if (this.state.typingTimeout) clearTimeout(this.state.typingTimeout);

    this.setState({
      typingTimeout: setTimeout(
        () => this.onSearch(searchTerm),
        autoSearchDelay
      ),
    });
  }

  render() {
    const {
      initialInputValue,
      settings: { autoSearchEnabled },
    } = this.props;
    return (
      <div>
        <ControlLabel srOnly>{__('Search')}</ControlLabel>
        <TypeAhead
          items={this.state.items}
          onInputUpdate={this.onInputUpdate}
          onSearch={this.onSearch}
          initialInputValue={initialInputValue}
          autoSearchEnabled={autoSearchEnabled}
        />
      </div>
    );
  }
}

Search.propTypes = {
  /** Callback function when the "Search" button is pressed:
      onSearch(searchQuery)
   */
  onSearch: PropTypes.func.isRequired,
  /** Function returning params for the scoped-search complete api call:
      getAutoCompleteParams(searchQuery)

      Should return a shape { headers, params, endpoint }, e.g.:
      {
        headers: {},
        params: { organization_id, search },
        endpoint: '/subscriptions/auto_complete_search'
      }
  */
  getAutoCompleteParams: PropTypes.func.isRequired,
  updateSearchQuery: PropTypes.func,
  initialInputValue: PropTypes.string,
  settings: PropTypes.shape({
    autoSearchEnabled: PropTypes.bool,
    autoSearchDelay: PropTypes.number,
  }),
};

Search.defaultProps = {
  updateSearchQuery: undefined,
  initialInputValue: '',
  settings: {
    autoSearchEnabled: false,
    autoSearchDelay: 500,
  },
};

export default Search;
