import React from 'react';
import { Provider } from 'react-redux';
import { storiesOf } from '@storybook/react';
import PropTypes from 'prop-types';
import Store from '../../redux';
import withTour from './';

const TouredComponent = ({ runTour }) => (
  <div style={{ margin: '50px' }}>
    <h4> This Component has a Tour !</h4> <br />
    <input data-tut="input" />
    <button data-tut="button" onClick={runTour}>
      Run Tour
    </button>
  </div>
);

TouredComponent.propTypes = {
  runTour: PropTypes.func.isRequired,
};

const steps = [
  { selector: 'input', content: 'Type Here ' },
  { selector: 'button', content: 'Click Here ' },
];
const Tour = withTour(TouredComponent, steps, 'id1');

storiesOf('Components/Tour', module).add('Tour', () => (
  <Provider store={Store}>
    <Tour />
  </Provider>
));
