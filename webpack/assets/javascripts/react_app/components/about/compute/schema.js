import React from 'react';
import ConnectedStatus from '../../common/status';
import { headerFormat, cellFormat } from '../../common/table';
import helpers from '../../../common/helpers';

export const columns = [
  {
    property: 'id',
    header: {
      label: 'Name',
      formatters: [headerFormat],
    },
    cell: {
      formatters: [
        cell => (
          <td>
            <a href={helpers.urlBuilder('compute_resources', '', cell.id)}>
              {cell.name}
            </a>
          </td>
        ),
      ],
    },
  },
  {
    property: 'type',
    header: {
      label: 'Type',
      formatters: [headerFormat],
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  {
    property: 'id',
    header: {
      label: 'Status',
      formatters: [headerFormat],
    },
    cell: {
      formatters: [
        cell => (
          <td id={`compute_resource${cell.id}_status`}>
            <ConnectedStatus
              data={{
                type: 'compute_resurce',
                id: cell.id,
                url: helpers.urlBuilder('compute_resources', 'ping', cell.id),
              }}
            />
          </td>
        ),
      ],
    },
  },
];
