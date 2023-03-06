import React, { useState } from 'react';
import PropTypes from 'prop-types';

import DiffView from './DiffView';
import DiffToggle from './DiffToggle';
import { SPLIT } from './DiffConsts';

import './diffview.scss';

const DiffContainer = ({ patch, oldText, newText, className }) => {
  const [viewType, setViewType] = useState(SPLIT);

  return (
    <div id="diff-container" className={className}>
      <DiffToggle changeState={setViewType} stateView={viewType} />
      <div id="diff-table" role="table" aria-label="diff-table">
        <DiffView
          patch={patch}
          oldText={oldText}
          newText={newText}
          viewType={viewType}
        />
      </div>
    </div>
  );
};

DiffContainer.propTypes = {
  oldText: PropTypes.string,
  newText: PropTypes.string,
  patch: PropTypes.string,
  className: PropTypes.string,
};

DiffContainer.defaultProps = {
  oldText: '',
  newText: '',
  patch: '',
  className: '',
};

export default DiffContainer;
