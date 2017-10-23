import React from 'react';
import { connect } from 'react-redux';
import { Modal, Button, OverlayTrigger, Tooltip } from 'patternfly-react';
import PropTypes from 'prop-types';
import helpers from '../../common/helpers';
import DonutChart from '../common/charts/DonutChart';
import Loader from '../common/Loader';
import MessageBox from '../common/MessageBox';
import { STATUS } from '../../constants';
import * as FactChartActions from '../../redux/actions/factCharts/';

import { navigateToSearch } from '../../../services/ChartService';

class FactChart extends React.Component {
  constructor(props) {
    super(props);
    helpers.bindMethods(this, ['openModal', 'closeModal']);
  }

  openModal() {
    const { showModal, getChartData, data: { id, path, title } } = this.props;

    getChartData(path, id);
    showModal(id, title);
  }

  closeModal() {
    this.props.closeModal();
  }

  render() {
    const {
      factChart,
      data: { id, title, search },
      modalToDisplay,
    } = this.props;

    const handleChartClick =
      search && search.match(/=$/) ? null : navigateToSearch.bind(null, search);

    const chartProps = {
      data: factChart.chartData ? factChart.chartData : null,
      key: `chart-${id}`,
      onclick: handleChartClick,
    };

    const chart = <DonutChart {...chartProps} config='large' />;

    const requestErrorMsg =
      factChart.loaderStatus === STATUS.ERROR
        ? __('Request Failed')
        : __('No data available');

    const error = modalToDisplay ? (
      <MessageBox
        msg={requestErrorMsg}
        icontype='error-circle-o'
        key={`message-${id}`}
      />
    ) : (
      false
    );

    const tooltip = (
      <Tooltip id={`viewChartTooltip-${id}`}>{__('Show distribution chart')}</Tooltip>
    );

    return (
      <div>
        <OverlayTrigger placement='top' overlay={tooltip}>
          <Button onClick={this.openModal}>{__('View Chart')}</Button>
        </OverlayTrigger>
        {modalToDisplay && (
          <Modal show={true} onHide={this.closeModal}>
            <Modal.Header closeButton>
              <Modal.Title>
                <b>
                  {// eslint-disable-next-line no-undef
                  Jed.sprintf(__('Fact distribution chart - %s '), title)}
                </b>
                <small>
                  {// eslint-disable-next-line no-undef
                  Jed.sprintf(
                    __('(%s host)', '(%s hosts)', factChart.hostsCount),
                    factChart.hostsCount,
                  )}
                </small>
              </Modal.Title>
            </Modal.Header>
            <Modal.Body>
              <Loader status={factChart.loaderStatus}>{[chart, error]}</Loader>
            </Modal.Body>
          </Modal>
        )}
      </div>
    );
  }
}

FactChart.propTypes = {
  factChart: PropTypes.object,
  modalToDisplay: PropTypes.bool,
  data: PropTypes.object,
};

const mapStateToProps = (state, ownProps) => ({
  factChart: state.factChart,
  modalToDisplay: state.factChart.modalToDisplay[ownProps.data.id] || false,
});

export default connect(mapStateToProps, FactChartActions)(FactChart);
