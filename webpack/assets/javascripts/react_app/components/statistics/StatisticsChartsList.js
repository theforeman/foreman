import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

import ChartBox from './ChartBox';
import * as StatisticsChartActions from '../../redux/actions/statistics';
import { STATUS } from '../../constants';
import './StatisticsChartsListStyles.scss';
import { translate as __ } from '../../../react_app/common/I18n';
import { noop } from '../../common/helpers';

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
    const charts = Object.values(this.props.charts).map(chart => (
      <ChartBox
        key={chart.id}
        type="donut"
        chart={chart}
        noDataMsg={__('No data available')}
        tip={__('Expand the chart')}
        errorText={chart.error && chart.error.message}
        id={chart.id}
        status={getStatusFromChart(chart)}
        title={chart.title}
        search={chart.search}
      />
    ));

    return (
      <div className="statistics-charts-list-root">
        {this.props.charts && charts.length && charts}
      </div>
    );
  }
}

StatisticsChartsList.propTypes = {
  data: PropTypes.array.isRequired,
  charts: PropTypes.oneOfType([PropTypes.array, PropTypes.object]),
  getStatisticsData: PropTypes.func,
};

StatisticsChartsList.defaultProps = {
  getStatisticsData: noop,
  charts: [],
};

const mapStateToProps = state => ({
  charts: state.statistics.charts,
});

export default connect(
  mapStateToProps,
  StatisticsChartActions
)(StatisticsChartsList);
