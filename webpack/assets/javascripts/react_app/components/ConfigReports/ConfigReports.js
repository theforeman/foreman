import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'patternfly-react';
import cx from 'classnames';
import ChartBox from '../statistics/ChartBox';
import { translate as __ } from '../../common/I18n';
import { STATUS } from '../../constants';

const ConfigReports = (props) => {
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
      <Col md={4}>
        <ChartBox
          {...chartBoxProps}
          type="donut"
          chart={{ data: metricsChartData, id: 'report-metrics' }}
          title={__('Report Metrics')}
        />
      </Col>

      <Col md={4}>
        <ChartBox
          {...chartBoxProps}
          type="bar"
          chart={{ data: statusChartData, id: 'report-status' }}
          title={__('Report Status')}
        />
      </Col>
      <Col md={4}>
        <table className={cx(tableClasses, 'report-chart')}>
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
  }),
};

export default ConfigReports;
