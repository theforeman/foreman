import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import helpers from '../../common/helpers';
import PieChart from '../common/charts/PieChart/';
import {
  getLargePieChartConfig,
  navigateToSearch
} from '../../../services/ChartService';
import ChartModal from './ChartModal';
import Loader from '../common/Loader';
import MessageBox from '../common/MessageBox';

class ChartBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showModal: false };
    helpers.bindMethods(this, ['onClick', 'closeModal', 'openModal']);
  }

  onClick() {
    this.openModal();
  }

  openModal() {
    this.setState({ showModal: true });
  }

  closeModal() {
    this.setState({ showModal: false });
  }

  render() {
    const { chart } = this.props;

    const modalConfig = getLargePieChartConfig({
      data: this.props.chart.data,
      id: chart.id + 'Modal'
    });

    const tooltip = {
      onClick: this.onClick,
      title: this.props.tip,
      'data-toggle': 'tooltip',
      'data-placement': 'top'
    };
    const onclickChartClicked = chart.search && chart.search.match(/=$/) ?
      null :
      navigateToSearch.bind(null, chart.search);

    const _chart = (
      <PieChart
        key={this.props.chart.id + '-chart'}
        data={this.props.chart.data}
        onclick={onclickChartClicked}
      />
    );

    const error = (
      <MessageBox
        msg={this.props.errorText}
        key={this.props.chart.id + '-error'}
        icontype="error-circle-o"
      />
    );

    const boxHeader = (
      <h3 {...tooltip}>{this.props.title}</h3>
    );

    return (
      <Panel
        className="chart-box"
        header={boxHeader}
        key={this.props.chart.id}
      >
        <Loader status={this.props.status}>
          {[_chart, error]}
        </Loader>

        <ChartModal
          {...this.props}
          show={this.state.showModal}
          onHide={this.closeModal}
          onEnter={this.onEnter}
          config={modalConfig}
          title={this.props.title}
        />
      </Panel>
    );
  }
}

ChartBox.propTypes = {
  status: PropTypes.string.isRequired,
  config: PropTypes.object,
  modalConfig: PropTypes.object,
  id: PropTypes.string.isRequired,
  noDataMsg: PropTypes.string,
  errorText: PropTypes.string
};

export default ChartBox;
