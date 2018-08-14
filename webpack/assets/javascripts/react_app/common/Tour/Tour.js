import PropTypes from 'prop-types';
import React, { Component } from 'react';
import Tour from 'reactour';
import { noop } from '../helpers';
import TourButton from './TourButton';

const FOREMAN_COLOR = '#00759A';

export const wrapComponentWithTour = (WrappedComponent, steps, id) => {
  const tour = class TourComponent extends Component {
    constructor(props) {
      super(props);
      const { alreadySeen, registerTour } = this.props;
      if (!alreadySeen) {
        registerTour(id);
      }
      this.addDismissButton();
    }

    addDismissButton = () => {
      const lastStep = steps.length - 1;
      const lastStepContent = steps[lastStep].content;
      steps[lastStep].content = () => (
        <React.Fragment>
          {lastStepContent}
          <TourButton id={id} />
        </React.Fragment>
      );
    };

    isOpen = () => {
      // TODO: move to a selector
      const { alreadySeen, activeTour } = this.props;
      const inSession = sessionStorage.getItem(`TOUR_${id}`);
      if (inSession || alreadySeen) {
        return false;
      }

      return activeTour && activeTour[0] === id;
    };

    render() {
      const { startRunning, stopRunning, isLoading, alreadySeen } = this.props;

      if (isLoading || alreadySeen) return null;
      return (
        <React.Fragment>
          <Tour
            ref={node => {
              this.portal = node;
            }}
            steps={steps}
            isOpen={this.isOpen()}
            rounded={5}
            accentColor={FOREMAN_COLOR}
            onRequestClose={() => stopRunning(id)}
          />
          <WrappedComponent runTour={() => startRunning(id)} {...this.props} />
        </React.Fragment>
      );
    }
  };
  tour.propTypes = {
    registerTour: PropTypes.func,
    startRunning: PropTypes.func,
    stopRunning: PropTypes.func,
    alreadySeen: PropTypes.bool,
    running: PropTypes.bool,
    activeTour: PropTypes.array,
    isEnabled: PropTypes.bool,
    isLoading: PropTypes.bool,
  };

  tour.defaultProps = {
    registerTour: noop,
    startRunning: noop,
    stopRunning: noop,
    alreadySeen: false,
    running: false,
    activeTour: [],
    isEnabled: true,
    isLoading: false,
  };

  return tour;
};
