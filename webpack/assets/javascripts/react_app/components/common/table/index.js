import { Table as PfTable } from 'patternfly-react';
import React from 'react';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import EmptyState from '../emptyState';

export const headerFormat = value => <PfTable.Heading>{value}</PfTable.Heading>;
export const cellFormat = value => <PfTable.Cell>{value}</PfTable.Cell>;
export const ellipsisFormat = value => (
  <PfTable.Cell>
    <EllipsisWithTooltip>{value}</EllipsisWithTooltip>
  </PfTable.Cell>
);

class Table extends React.Component {
  isEmpty() {
    return this.props.rows.length === 0;
  }

  render() {
    const { columns, rows, emptyState } = this.props;
    return this.isEmpty() ? (
      <EmptyState {...emptyState} />
    ) : (
      <PfTable.PfProvider
        className="table-fixed"
        striped
        bordered
        hover
        columns={columns}
      >
        <PfTable.Header />
        <PfTable.Body
          rows={rows}
          rowKey={({ rowData, rowIndex }) => rowIndex}
        />
      </PfTable.PfProvider>
    );
  }
}
export default Table;
