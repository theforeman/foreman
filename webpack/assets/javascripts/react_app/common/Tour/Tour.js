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
      if (this.props.alreadySeen === undefined) {
        this.props.registerTour(id);
      }
      this.addTourButton();
    }

    addTourButton = () => {
      const lastStep = steps.length - 1;
      const lastStepContent = steps[lastStep].content;
      steps[lastStep].content = () => (
        <div>
          {lastStepContent}
          <TourButton id={id} />
        </div>
      );
    };

    isOpen = () => {
      const { alreadySeen, activeTour, isEnabled } = this.props;
      const inSession = sessionStorage.getItem(`TOUR_${id}`);

      if (!isEnabled || inSession || alreadySeen) {
        return false;
      }
      return activeTour && activeTour[0] === id;
    };

    render() {
      const { startRunnig, stopRunning } = this.props;

      return (
        <div>
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
          <WrappedComponent
            runTour={() => setTimeout(() => startRunnig(id), 500)}
            {...this.props}
          />
        </div>
      );
    }
  };
  tour.propTypes = {
    startRunning: PropTypes.func,
    stopRunning: PropTypes.func,
    alreadySeen: PropTypes.bool,
    running: PropTypes.bool,
    activeTour: PropTypes.array,
    isEnabled: PropTypes.bool,
  };

  tour.defaultProps = {
    startRunning: noop,
    stopRunning: noop,
    alreadySeen: false,
    running: false,
    activeTour: [],
    isEnabled: true,
  };

  return tour;
};
