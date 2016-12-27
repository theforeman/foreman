import React, {PropTypes} from 'react';
import helpers from '../../common/helpers';
import Chart from './Chart';
import chartService from '../../../services/statisticsChartService';
import ChartModal from './ChartModal';
import Loader from '../common/Loader';
import Panel from '../common/Panel/Panel';
import PanelHeading from '../common/Panel/PanelHeading';
import PanelTitle from '../common/Panel/PanelTitle';
import PanelBody from '../common/Panel/PanelBody';
import './StatisticsChartsListStyles.css';
import MessageBox from '../common/MessageBox';

class ChartBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showModal: false};
    helpers.bindMethods(this, [
      'onClick',
      'closeModal',
      'openModal']
    );
  }

  onClick() {
    if (this.props.modalConfig.data.columns.length) {
      this.openModal();
    }
  }

  openModal() {
    this.setState({ showModal: true });
  }

  closeModal() {
    this.setState({ showModal: false });
  }

  render() {
    const tooltip = {
      onClick: this.onClick,
      title: this.props.tip,
      'data-toggle': 'tooltip',
      'data-placement': 'top'
    };

    const chart = (<Chart {...this.props} key="0"
                          config={this.props.config}
                          noDataMsg={this.props.noDataMsg}
                          cssClass="statistics-pie small"
                          setTitle={chartService.setTitle}/>);

    const error = (<MessageBox msg={this.props.errorText}
                               icontype="error-circle-o" key="1"></MessageBox>);

    return (
      <Panel className="statistics-charts-list-panel">
        <PanelHeading {...tooltip} className="statistics-charts-list-heading">
          <PanelTitle text={this.props.title}/>
        </PanelHeading>

        <PanelBody className="statistics-charts-list-body">
          <Loader status={this.props.status}>
            {[chart, error]}
          </Loader>

          <ChartModal {...this.props}
                      show={this.state.showModal}
                      onHide={this.closeModal}
                      onEnter={this.onEnter}
                      config={this.props.modalConfig}
                      title={this.props.title}
                      id={this.props.id + 'Modal'}
                      setTitle={chartService.setTitle}
          />
        </PanelBody>
      </Panel >
    );
  }
}

ChartBox.PropTypes = {
  status: PropTypes.string.isRequired,
  config: PropTypes.object,
  modalConfig: PropTypes.object,
  id: PropTypes.string.isRequired,
  noDataMsg: PropTypes.string,
  errorText: PropTypes.string
};

export default ChartBox;
