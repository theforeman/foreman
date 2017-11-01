import React from 'react';
import PropTypes from 'prop-types';
import ChartBox from './ChartBox';
import './StatisticsChartsListStyles.css';
import { connect } from 'react-redux';
import * as StatisticsChartActions from '../../redux/actions/statistics';
import { STATUS } from '../../constants';
import _ from 'lodash';

const getStatusFromChart = chart => {
  if (chart.data) {
    return STATUS.RESOLVED;
  }
  if (chart.error) {
    return STATUS.ERROR;
  }
  return STATUS.PENDING;
};

class StatisticsChartsList extends React.Component {
  componentDidMount() {
    const { getStatisticsData, data } = this.props;

    getStatisticsData(data);
  }

  render() {
    const charts = _.map(this.props.charts, chart => {
      return (
        <ChartBox
          key={chart.id}
          chart={chart}
          noDataMsg={__('No data available')}
          tip={__('Expand the chart')}
          errorText={chart.error}
          id={chart.id}
          status={getStatusFromChart(chart)}
          title={chart.title}
          search={chart.search}
        />
      );
    });

    return (
      <div className="statistics-charts-list-root">
        {this.props.charts && charts}
      </div>
    );
  }
}

StatisticsChartsList.propTypes = {
  data: PropTypes.array.isRequired,
};

const mapStateToProps = state => ({
  charts: state.statistics.charts,
});

export default connect(mapStateToProps, StatisticsChartActions)(
  StatisticsChartsList
);
