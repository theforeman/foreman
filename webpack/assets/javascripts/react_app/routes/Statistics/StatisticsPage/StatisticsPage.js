import React from 'react';
import PropTypes from 'prop-types';
import PageLayout from '../../../pages/common/PageLayout/PageLayout';
import Statistics from './Statistics/Statistics';

const StatisticsPage = ({ statisticsMeta, ...props }) => (
  <PageLayout header={__('Statistics')} searchable={false}>
    <Statistics statisticsMeta={statisticsMeta} {...props} />
  </PageLayout>
);

StatisticsPage.propTypes = {
  statisticsMeta: PropTypes.array,
};

StatisticsPage.defaultProps = {
  statisticsMeta: [],
};

export default StatisticsPage;
