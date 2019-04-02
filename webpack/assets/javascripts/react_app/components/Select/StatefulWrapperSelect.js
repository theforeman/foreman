import React, { Component } from 'react';
import { Select } from './index';
import { optionsArray } from './Select.fixtures';

class StatefulWrapperSelect extends Component {
  state = {
    open: false,
    cursor: 0,
    isSearching: false,
    searchValue: '',
    selected: { id: '3', name: 'selected' },
    isLoading: false,
    options: optionsArray,
    matched: [],
  };

  onToggle = () =>
    this.setState({
      open: !this.state.open,
      isSearching: false,
      searchValue: '',
      cursor: 0,
    });

  matcher = search => {
    const { options } = this.state;
    const results = [];
    options.forEach(opt => {
      if (opt.name.includes(search)) results.push(opt);
    });
    return results;
  };

  onSearch = e => {
    e.persist();
    if (e.target.value !== '') {
      this.setState(
        {
          searchValue: e.target.value,
          isSearching: true,
          isLoading: true,
          cursor: 0,
        },
        () => {
          setTimeout(() => {
            this.setState({
              isLoading: false,
              matched: this.matcher(e.target.value),
            });
          }, 700);
        }
      );
    } else this.setState({ isSearching: false, searchValue: '' });
  };

  onClear = () => this.setState({ searchValue: '', isSearching: false });

  onChange = host =>
    this.setState({
      selected: { id: host.id, name: host.name },
      open: false,
      isSearching: false,
      searchValue: '',
    });

  onKeyDown = e => {
    const { matched, isSearching } = this.state;
    const options = isSearching ? matched : this.state.options;
    const { cursor } = this.state;
    if (e.keyCode === 38 && cursor > 0) {
      e.preventDefault();
      this.setState(prevState => ({
        cursor: prevState.cursor - 1,
      }));
    }
    if (e.keyCode === 40 && cursor < options.length - 1) {
      e.preventDefault();
      this.setState(prevState => ({
        cursor: prevState.cursor + 1,
      }));
    }
    if (e.keyCode === 13 && cursor >= 0 && !options[cursor].disabled)
      this.onChange(options[cursor]);
  };

  render() {
    const {
      open,
      isSearching,
      searchValue,
      selected,
      isLoading,
      options,
      matched,
      cursor,
    } = this.state;
    return (
      <Select
        options={isSearching ? matched : options}
        cursor={cursor}
        onKeyDown={this.onKeyDown}
        placeholder="Filter Host..."
        open={open}
        onToggle={this.onToggle}
        searchValue={searchValue}
        onSearchChange={this.onSearch}
        onSearchClear={this.onClear}
        onChange={this.onChange}
        selectedItem={selected}
        isLoading={isLoading}
        {...this.props}
      />
    );
  }
}

export default StatefulWrapperSelect;
