import React, { useEffect } from 'react';
import { Spinner } from 'patternfly-react';
import PropTypes from 'prop-types';
import { Table } from '../common/table';
import { STATUS } from '../../constants';
import MessageBox from '../common/MessageBox';
import { translate as __ } from '../../common/I18n';
import createReportTemplatesTableSchema from './ReportTemplatesTableSchema';
import { getURIQuery } from '../../common/helpers';

const ReportTemplatesTable = ({
  getTableItems,
  sortBy,
  sortOrder,
  error,
  status,
  results,
}) => {
  useEffect(() => {
    getTableItems(getURIQuery(window.location.href));
  }, [getTableItems]);

  if (results.length === 0) {
    return <Spinner size="lg" loading />;
  }

  if (status === STATUS.ERROR) {
    return (
      <MessageBox
        key="report-templates-table-error"
        icontype="error-circle-o"
        msg={__(`Could not receive data: ${error && error.message}`)}
      />
    );
  }

  const availableActions = {
    generate: (templateId, templateName) => {
      return `report_templates/${templateId}/generate`;
    },
    clone: (templateId, templateName) => {
      return `report_templates/${templateId}/clone_template`;
    },
    export: (templateId, templateName) => {
      return `report_templates/${templateId}/export`;
    },
    lock: (templateId, templateName) => {
      return `report_templates/${templateId}/lock`;
    },
    unlock: (templateId, templateName) => {
      return `report_templates/${templateId}/unlock`;
    },
    delete: (templateId, templateName) => {
      return `report_templates/${templateId}/delete`;
    },
  };

  return (
    <Table
      key="report-templates-table"
      columns={createReportTemplatesTableSchema(getTableItems, sortBy, sortOrder, availableActions)}
      rows={results}
    />
  );
};

ReportTemplatesTable.propTypes = {
  results: PropTypes.array.isRequired,
  getTableItems: PropTypes.func.isRequired,
  status: PropTypes.oneOf(Object.keys(STATUS)),
  sortBy: PropTypes.string,
  sortOrder: PropTypes.string,
  error: PropTypes.object,
};

ReportTemplatesTable.defaultProps = {
  status: STATUS.PENDING,
  sortBy: '',
  sortOrder: '',
  error: null,
};

export default ReportTemplatesTable;
