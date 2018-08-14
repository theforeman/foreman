import React from 'react';
import PropTypes from 'prop-types';
import withTour from './';
import BasicWrappedComponent from './BasicWrappedComponent';

const BasicTour = ({ data: { steps, id } }) => {
  const MyTour = withTour(BasicWrappedComponent, steps, id);

  return <MyTour />;
};

BasicTour.propTypes = {
  data: PropTypes.shape({
    steps: PropTypes.arrayOf(
      PropTypes.shape({
        selector: PropTypes.string,
        content: PropTypes.string,
      })
    ),
    id: PropTypes.string,
  }).isRequired,
};

export default BasicTour;
