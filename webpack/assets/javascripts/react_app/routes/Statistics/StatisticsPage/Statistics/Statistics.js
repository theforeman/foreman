import React from 'react';
import PropTypes from 'prop-types';
import { withRenderHandler } from '../../../../common/HOC';
import StatisticsChartsList from '../../../../components/StatisticsChartsList';

const Statistics = ({ statisticsMeta }) => (
  <StatisticsChartsList data={statisticsMeta} />
);

Statistics.propTypes = {
  statisticsMeta: PropTypes.array.isRequired,
};

export default withRenderHandler({
  Component: Statistics,
});
