import React from 'react';
import { Spinner } from 'patternfly-react';
import PropTypes from 'prop-types';
import { Table } from '../common/table';
import { STATUS } from '../../constants';
import MessageBox from '../common/MessageBox';
import { translate as __ } from '../../common/I18n';
import createModelsTableSchema from './ModelsTableSchema';
import { getURIQuery } from '../../common/helpers';

class ModelsTable extends React.Component {
  componentDidMount() {
    this.props.getTableItems(getURIQuery(window.location.href));
  }

  render() {
    const {
      getTableItems,
      sortBy,
      sortOrder,
      error,
      status,
      results,
    } = this.props;

    const renderTable =
      status === STATUS.ERROR ? (
        <MessageBox
          key="models-table-error"
          icontype="error-circle-o"
          msg={__(`Could not receive data: ${error && error.message}`)}
        />
      ) : (
        <Table
          key="models-table"
          columns={createModelsTableSchema(getTableItems, sortBy, sortOrder)}
          rows={results}
        />
      );

    if (results.length > 0) {
      return renderTable;
    }
    return <Spinner size="lg" loading />;
  }
}

ModelsTable.propTypes = {
  results: PropTypes.array.isRequired,
  getTableItems: PropTypes.func.isRequired,
  status: PropTypes.oneOf(Object.keys(STATUS)),
  sortBy: PropTypes.string,
  sortOrder: PropTypes.string,
  error: PropTypes.object,
};

ModelsTable.defaultProps = {
  status: STATUS.PENDING,
  sortBy: '',
  sortOrder: '',
  error: null,
};

export default ModelsTable;
