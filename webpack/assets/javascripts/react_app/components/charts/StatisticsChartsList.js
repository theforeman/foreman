import React, { PropTypes } from 'react';
import chartService from '../../../services/statisticsChartService';
import ChartBox from './ChartBox';
import './StatisticsChartsListStyles.css';
import { connect } from 'react-redux';
import * as StatisticsChartActions from '../../redux/actions/statistics';
import { STATUS } from '../../constants';

const getStatusFromChart = (chart) => {
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
    const noDataMsg = __('No data available').toString();
    const tip = __('Expand the chart').toString();
    const charts = this.props.charts.map(chart => {
      const config = chartService.getChartConfig(chart);

      chartService.syncConfigData(config, chart.data);
      const modalConfig = chartService.getModalChartConfig(chart);

      chartService.syncConfigData(modalConfig, chart.data);

      return (
        <ChartBox
          key={chart.id}
          config={config}
          modalConfig={modalConfig}
          noDataMsg={noDataMsg}
          tip={tip}
          errorText={chart.error}
          id={chart.id}
          status={ getStatusFromChart(chart) }
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

StatisticsChartsList.PropTypes = {
  data: PropTypes.array.isRequired
};

const mapStateToProps = state => ({
  charts: state.statistics.charts
});

export default connect(mapStateToProps, StatisticsChartActions)(
  StatisticsChartsList
);
