import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { Modal } from 'patternfly-react';
import { isEqual } from 'lodash';
import helpers from '../../common/helpers';
import DonutChart from '../common/charts/DonutChart';
import { navigateToSearch } from '../../../services/ChartService';
import Loader from '../common/Loader';
import MessageBox from '../common/MessageBox';

class ChartBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showModal: false };
    helpers.bindMethods(this, ['onClick', 'closeModal', 'openModal']);
  }
  shouldComponentUpdate(nextProps, nextState) {
    return (
      !isEqual(this.props.chart, nextProps.chart) ||
      !isEqual(this.state, nextState)
    );
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
    const { chart, type } = this.props;
    const components = {
      donut: DonutChart,
    };
    const Chart = components[type];
    const dataFiltered = chart.data && chart.data.filter(arr => arr[1] !== 0);
    const hasChartData = dataFiltered && dataFiltered.length > 0;
    const headerProps = hasChartData
      ? {
          onClick: this.onClick,
          title: this.props.tip,
          'data-toggle': 'tooltip',
          'data-placement': 'top',
        }
      : {};
    const handleChartClick =
      chart.search && chart.search.match(/=$/)
        ? null
        : navigateToSearch.bind(null, chart.search);
    const chartProps = {
      data: chart.data ? chart.data : undefined,
      key: `${this.props.chart.id}-chart`,
      onclick: handleChartClick,
    };
    const panelChart = <Chart {...chartProps} />;
    const error = (
      <MessageBox
        msg={this.props.errorText}
        key={`${this.props.chart.id}-error`}
        icontype="error-circle-o"
      />
    );
    const boxHeader = (
      <h3 className="pointer panel-title" {...headerProps}>
        {this.props.title}
      </h3>
    );

    return (
      <Panel className="chart-box" header={boxHeader} key={this.props.chart.id}>
        <Panel.Heading>{boxHeader}</Panel.Heading>
        <Panel.Body>
          <Loader status={this.props.status}>{[panelChart, error]}</Loader>
          {this.state.showModal && (
            <Modal
              show={this.state.showModal}
              enforceFocus
              onHide={this.closeModal}
            >
              <Modal.Header closeButton>
                <Modal.Title>{this.props.title}</Modal.Title>
              </Modal.Header>
              <Modal.Body>
                <Chart {...chartProps} config="large" />;
              </Modal.Body>
            </Modal>
          )}
        </Panel.Body>
      </Panel>
    );
  }
}

ChartBox.propTypes = {
  status: PropTypes.string.isRequired,
  config: PropTypes.object,
  id: PropTypes.string.isRequired,
  noDataMsg: PropTypes.string,
  errorText: PropTypes.string,
  type: PropTypes.oneOf(['donut']).isRequired,
  chart: PropTypes.object,
  tip: PropTypes.string,
};

export default ChartBox;
