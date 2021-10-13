import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Select } from 'patternfly-react-extensions';
import { translate as __ } from '../../../common/I18n';
import './editorhostselect.scss';

class EditorHostSelect extends Component {
  componentDidMount() {
    document.addEventListener('mousedown', this.handleClickOutside);
  }

  componentWillUnmount() {
    document.removeEventListener('mousedown', this.handleClickOutside);
  }

  setWrapperRef = (node) => {
    this.selectRef = node;
  };

  handleClickOutside = (event) => {
    if (this.selectRef && !this.selectRef.contains(event.target)) {
      const { open, onToggle } = this.props;
      if (open) onToggle();
    }
  };

  onKey = (event) => {
    if (event.keyCode === 27) {
      const { open, onToggle } = this.props;
      if (open) onToggle();
    }
  };

  render() {
    const {
      show,
      isLoading,
      onChange,
      onSearchChange,
      onSearchClear,
      onToggle,
      open,
      options,
      searchQuery,
      selectedItem,
    } = this.props;
    return (
      <div
        ref={this.setWrapperRef}
        id="editor-select-container"
        className={show ? '' : 'hidden'}
      >
        <Select
          options={options}
          placeholder={__('Filter Host...')}
          open={open}
          onToggle={onToggle}
          searchValue={searchQuery}
          onSearchChange={onSearchChange}
          onSearchClear={onSearchClear}
          onKeyDown={this.onKey}
          onItemClick={onChange}
          selectedItem={selectedItem}
          isLoading={isLoading}
        />
      </div>
    );
  }
}

EditorHostSelect.propTypes = {
  show: PropTypes.bool.isRequired,
  isLoading: PropTypes.bool.isRequired,
  onChange: PropTypes.func.isRequired,
  onSearchChange: PropTypes.func.isRequired,
  onSearchClear: PropTypes.func.isRequired,
  onToggle: PropTypes.func.isRequired,
  open: PropTypes.bool.isRequired,
  options: PropTypes.array.isRequired,
  searchQuery: PropTypes.string.isRequired,
  selectedItem: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    name: PropTypes.string,
  }).isRequired,
};

export default EditorHostSelect;
