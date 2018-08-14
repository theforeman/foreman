import PropTypes from 'prop-types';
import React, { Component } from 'react';
import { noop } from '../helpers';

class BasicWrappedComponent extends Component {
  componentDidMount() {
    this.props.runTour();
  }
  render() {
    return <div />;
  }
}

BasicWrappedComponent.propTypes = {
  runTour: PropTypes.func,
};

BasicWrappedComponent.defaultProps = {
  runTour: noop,
};

export default BasicWrappedComponent;
