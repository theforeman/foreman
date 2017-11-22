import React from 'react';
import { headerFormat, cellFormat, ellipsisFormat } from '../../common/table';

export const columns = () => [
  {
    property: 'name',
    header: {
      label: __('Name'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [
        cell => (
          <td>
            <a href={cell.url}>
              {cell.name}
            </a>
          </td>
        ),
      ],
    },
  },
  {
    property: 'description',
    header: {
      label: __('Description'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [ellipsisFormat],
    },
  },
  {
    property: 'author',
    header: {
      label: __('Author'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [ellipsisFormat],
    },
  },
  {
    property: 'version',
    header: {
      label: __('Version'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [cellFormat],
    },
  },
];
