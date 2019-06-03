import React from 'react';
import PropTypes from 'prop-types';
import { bindMethods } from '../../common/helpers';

import DiffView from './DiffView';
import DiffRadioButtons from './DiffRadioButtons';
import './diffview.scss';

class DiffContainer extends React.Component {
  constructor(props) {
    super(props);
    bindMethods(this, ['changeState']);
    this.state = {
      viewType: 'split',
    };
  }

  changeState(viewType) {
    this.setState({ viewType });
  }

  render() {
    const { patch, oldText, newText, className } = this.props;
    const { viewType } = this.state;
    return (
      <div id="diff-container" className={className}>
        <DiffRadioButtons changeState={this.changeState} stateView={viewType} />
        <div id="diff-table">
          <DiffView
            patch={patch}
            oldText={oldText}
            newText={newText}
            viewType={viewType}
          />
        </div>
      </div>
    );
  }
}

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
