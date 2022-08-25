import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { Table, TableHeader, TableBody } from '@patternfly/react-table';
import GlobalStatusIcon from './GlobalStatusIcon';
import LinkOrLabel from './LinkOrLabel';
import { translate as __ } from '../../../common/I18n';

const Details = ({ data }) => {
  const columns = ['', __('Total'), __('Owned')];
  const rows = data.map(
    ({
      label,
      total,
      owned,
      global_status: globalStatus,
      total_path: totalPath,
      owned_path: ownedPath,
    }) => [
      {
        title: (
          <Fragment>
            <GlobalStatusIcon status={globalStatus} /> {label}
          </Fragment>
        ),
      },
      { title: <LinkOrLabel path={totalPath} label={total.toString()} /> },
      { title: <LinkOrLabel path={ownedPath} label={owned.toString()} /> },
    ]
  );

  return (
    <Table
      ouiaId="host-statuses-table"
      aria-label="Host Statuses"
      variant="compact"
      cells={columns}
      rows={rows}
    >
      <TableHeader />
      <TableBody />
    </Table>
  );
};

Details.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string.isRequired,
      total: PropTypes.number.isRequired,
      owned: PropTypes.number.isRequired,
      global_status: PropTypes.number,
      total_path: PropTypes.string,
      owned_path: PropTypes.string,
    })
  ),
};

Details.propTypes = {
  data: PropTypes.array,
};

Details.defaultProps = {
  data: [],
};

export default Details;
