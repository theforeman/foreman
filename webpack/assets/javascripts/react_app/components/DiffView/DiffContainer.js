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
    const { oldText, newText } = this.props;
    const { viewType } = this.state;
    return (
      <div id="diff-container">
        <DiffRadioButtons changeState={this.changeState} stateView={viewType} />
        <div id="diff-table">
          <DiffView oldText={oldText} newText={newText} viewType={viewType} />
        </div>
      </div>
    );
  }
}

DiffContainer.propTypes = {
  oldText: PropTypes.string.isRequired,
  newText: PropTypes.string.isRequired,
};

export default DiffContainer;
