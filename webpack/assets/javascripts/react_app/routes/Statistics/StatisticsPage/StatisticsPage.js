import React from 'react';
import PropTypes from 'prop-types';
import PageLayout from '../../common/PageLayout/PageLayout';
import Statistics from './Statistics/Statistics';
import { translate as __ } from '../../../common/I18n';

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
