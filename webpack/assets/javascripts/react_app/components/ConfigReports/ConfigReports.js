import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'patternfly-react';
import classNames from 'classnames';
import ChartBox from '../ChartBox/ChartBox';
import { translate as __ } from '../../common/I18n';
import { STATUS } from '../../constants';

import './ConfigReports.scss';

const ConfigReports = props => {
  const {
    metricsChartData,
    statusChartData,
    metricsData: { tableData, tableClasses, total },
  } = props.data;

  const createRow = ([name, value], i) => (
    <tr key={i}>
      <td className="break-me">{name}</td>
      <td>{value}</td>
    </tr>
  );

  const chartBoxProps = {
    className: 'report-chart',
    noDataMsg: __('No data available'),
    status: STATUS.RESOLVED,
    config: 'medium',
  };

  return (
    <Row>
      <Col md={5}>
        <ChartBox
          {...chartBoxProps}
          type="donut"
          chart={{ data: metricsChartData, id: 'report-metrics' }}
          title={__('Report Metrics')}
        />
      </Col>

      <Col md={5} className="bar-chart-medium-width">
        <ChartBox
          {...chartBoxProps}
          type="bar"
          chart={{ data: statusChartData, id: 'report-status' }}
          title={__('Report Status')}
        />
      </Col>
      <Col md={2}>
        <table className={classNames(tableClasses, 'report-chart')}>
          <tbody>{tableData.map((metric, i) => createRow(metric, i))}</tbody>
          <tfoot>
            <tr>
              <th>{__('Total')}</th>
              <th>{total}</th>
            </tr>
          </tfoot>
        </table>
      </Col>
    </Row>
  );
};

ConfigReports.propTypes = {
  data: PropTypes.shape({
    metricsChartData: PropTypes.array,
    statusChartData: PropTypes.array,
    metricsData: PropTypes.shape({
      tableData: PropTypes.array,
      total: PropTypes.number,
      tableClasses: PropTypes.string,
    }),
  }).isRequired,
};

export default ConfigReports;
