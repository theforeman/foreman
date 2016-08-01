import React from 'react';
import StatisticsChartBox from './StatisticsChartBox';
import styles from './StatisticsChartsListStyles';

const StatisticsChartsList = ({data}) => {
    let charts = [];

    data.forEach(chart => {
      charts.push(<StatisticsChartBox key={chart.id} {...chart} />);
    });

    return (
      <div className="collection" style={styles.root}>
        {charts}
      </div>
    );
};

export default StatisticsChartsList;
