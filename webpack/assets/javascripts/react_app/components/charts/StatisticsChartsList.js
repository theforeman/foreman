import React, {PropTypes} from 'react';
import helpers from '../../common/helpers';
import chartService from '../../../services/statisticsChartService';
import StatisticsChartBox from './StatisticsChartBox';
import { STATUS } from '../../constants';
import StatisticsStore from '../../stores/StatisticsStore';
import StatisticsChartActions from '../../actions/StatisticsChartActions';
import './StatisticsChartsListStyles.css';

class StatisticsChartsList extends React.Component {
  constructor(props) {
    super(props);

    this.state = {charts: this.stateSetup(this.props.data)};

    helpers.bindMethods(this, [
      'onChange',
      'onError']
    );
  }

  stateSetup(data) {
    let chartStates = {};

    data.forEach(chart => {
      chartStates[chart.id] = {};
    });

    return chartStates;
  }

  componentDidMount() {
    StatisticsStore.addChangeListener(this.onChange);
    StatisticsStore.addErrorListener(this.onError);

    let chartStates = this.cloneChartStates();

    this.props.data.forEach(chart => {
      StatisticsChartActions.getStatisticsData(chart.url);
      chartStates[chart.id].status = STATUS.PENDING;
    });

    this.updateStateCharts(chartStates);
  }

  cloneChartStates() {
    return Object.assign({}, this.state.charts);
  }

  updateStateCharts(chartStates) {
    this.setState({ charts: chartStates });
  }

  componentWillUnmount() {
    StatisticsStore.removeChangeListener(this.onChange);
    StatisticsStore.removeErrorListener(this.onError);
  }

  onChange(event) {
    const id = event.id;
    const statistics = StatisticsStore.getStatisticsData(id);
    let chartStates = this.cloneChartStates();

    chartStates[id] = Object.assign({}, chartStates[id], {
      status: STATUS.RESOLVED,
      data: statistics.data
    });

    this.updateStateCharts(chartStates);
  }

  onError(info) {
    const xhr = info.jqXHR;
    const id = xhr.originalRequestOptions.url.split('/')[1];

    let chartStates = this.cloneChartStates();

    chartStates[id] = Object.assign({}, chartStates[id], {
      status: STATUS.ERROR,
      errorText: info.errorThrown
    });

    this.updateStateCharts(chartStates);
  }

  render() {
    const noDataMsg = __('No data available').toString();
    let charts = [];
    const tip = __('Expand the chart').toString();

    this.props.data.forEach(chart => {
      let config, modalConfig;

      config = chartService.getChartConfig(chart);
      chartService.syncConfigData(config, this.state.charts[chart.id].data);
      modalConfig = chartService.getModalChartConfig(chart);
      chartService.syncConfigData(modalConfig, this.state.charts[chart.id].data);

      charts.push(
        <StatisticsChartBox
          key={chart.id}
          config={config}
          modalConfig={modalConfig}
          noDataMsg={noDataMsg}
          tip={tip}
          status={this.state.charts[chart.id].status || STATUS.PENDING}
          errorText={this.state.charts[chart.id].errorText}
          id={chart.id}
          title={chart.title}
          search={chart.search}
        />
      );
    });

    return (
      <div className="statistics-charts-list-root">
        {charts}
      </div>
    );
  }
}

StatisticsChartsList.PropTypes = {
  data: PropTypes.array.isRequired
};

export default StatisticsChartsList;
