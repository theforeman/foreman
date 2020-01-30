import React from 'react';
import PropTypes from 'prop-types';
import { withRenderHandler } from '../../../../common/HOC';
import StatisticsChartsList from '../../../../components/StatisticsChartsList';
import { translate as __ } from '../../../../common/I18n';
import { EmptyStatePattern } from '../../../../components/common/EmptyState';

const Statistics = ({ statisticsMeta }) => {
  if (!statisticsMeta) {
    return (
      <EmptyStatePattern
        icon="info"
        header={__('No Charts To Load')}
        description=""
      />
    );
  }
  return <StatisticsChartsList data={statisticsMeta} />;
};

Statistics.propTypes = {
  statisticsMeta: PropTypes.array.isRequired,
};

export default withRenderHandler({
  Component: Statistics,
});
