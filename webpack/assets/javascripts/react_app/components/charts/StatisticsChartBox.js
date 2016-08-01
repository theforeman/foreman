import React from 'react';
import helpers from '../../common/helpers';
import { STATUS } from '../../constants';
import Chart from './Chart';
import ChartModal from './ChartModal';
import Loader from '../common/Loader';
import Panel from '../common/Panel/Panel';
import PanelHeading from '../common/Panel/PanelHeading';
import PanelTitle from '../common/Panel/PanelTitle';
import PanelBody from '../common/Panel/PanelBody';
import StatisticsStore from '../../stores/StatisticsStore';
import StatisticsChartActions from '../../actions/StatisticsChartActions';
import statisticsPage from '../../../pages/statistics_page';
import styles from './StatisticsChartsListStyles';
import MessageBox from '../common/MessageBox';

export default class StatisticsChartBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showModal: false, status: STATUS.PENDING };
    helpers.bindMethods(this, [
      'drawChart',
      'onChange',
      'onError',
      'onClick',
      'closeModal',
      'openModal',
      'drawModal']
    );
  }

  componentDidMount() {
    StatisticsChartActions.getStatisticsData(this.props.url);
    StatisticsStore.addChangeListener(this.onChange);
    StatisticsStore.addErrorListener(this.onError);
  }

  componentWillUnmount() {
    StatisticsStore.removeChangeListener(this.onChange);
    StatisticsStore.removeErrorListener(this.onError);
  }

  onChange(event) {
    if (event.id === this.props.id) {
      const statistics = StatisticsStore.getStatisticsData(this.props.id);

      this.setState({
        status: STATUS.RESOLVED,
        hasData: !!statistics.data.length,
        data: statistics.data
      });
    }
  }

  onError(info) {
    const xhr = info.jqXHR;
    const id = xhr.originalRequestOptions.url.split('/')[1];

    if (id === this.props.id) {
      this.setState({
        status: STATUS.ERROR,
        errorText: info.errorThrown
      });
    }
  }

  onClick() {
    if (this.state.data && this.state.hasData) {
      this.openModal();
    }
  }

  componentDidUpdate() {
    this.drawChart();
  }

  drawChart() {
    statisticsPage.generateChart(this.props, this.state.data);
  }

  openModal() {
    this.setState({ showModal: true });
  }

  closeModal() {
    this.setState({ showModal: false });
  }

  drawModal() {
    statisticsPage.generateModalChart(this.props, this.state.data);
  }

  render() {
    const tooltip = {
      onClick: this.onClick,
      title: __('Expand the chart').toString(),
      'data-toggle': 'tooltip',
      'data-placement': 'top'
    };

    const chart = (<Chart {...this.props} key="0"
                          drawChart={this.drawChart}
                          hasData={this.state.hasData}
                          noDataMsg={__('No data available').toString()}
                          cssClass="statistics-pie small"/>);

    const error = (<MessageBox msg={this.state.errorText}
                               icontype="error-circle-o" key="1"></MessageBox>);

    return (
      <Panel style={styles.panel}>
        <PanelHeading {...tooltip} style={styles.heading}>
          <PanelTitle text={this.props.title}/>
        </PanelHeading>

        <PanelBody style={styles.body}>
          <Loader status={this.state.status}>
            {[chart, error]}
          </Loader>

          <ChartModal {...this.props}
                      show={this.state.showModal}
                      onHide={this.closeModal}
                      drawChart={this.drawModal}
          />
        </PanelBody>
      </Panel >
    );
  }
}
