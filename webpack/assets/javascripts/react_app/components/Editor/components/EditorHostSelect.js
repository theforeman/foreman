import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { Select } from 'patternfly-react-extensions';
import { translate as __ } from '../../../common/I18n';
import './editorhostselect.scss';

const EditorHostSelect = props => {
  const {
    show,
    isLoading,
    onChange,
    onSearchChange,
    onSearchClear,
    open,
    onToggle,
    options,
    searchQuery,
    selectedItem,
  } = props;

  //
  // unused props ? :

  // placeholder={__('Select Host...')}
  // key="hostsSelect"
  //

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);

    // a function to execute on unmount:
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const [wrapperRef, setWrapperRef] = useState(null);

  const handleWrapperRefChange = node => {
    setWrapperRef(node);
  };

  const handleClickOutside = event => {
    if (wrapperRef && !wrapperRef.contains(event.target) && open) onToggle();
  };

  const onKey = event => {
    if (event.keyCode === 27 && open) onToggle();
  };

  return (
    <div
      ref={handleWrapperRefChange}
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
        onKeyDown={onKey}
        onItemClick={onChange}
        selectedItem={selectedItem}
        isLoading={isLoading}
      />
    </div>
  );
};

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
