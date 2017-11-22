import React from 'react';
import { Icon } from 'patternfly-react';
import { headerFormat, cellFormat } from '../../common/table';

export const columns = () => [
  {
    property: 'provider',
    header: {
      label: __('Provider'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  {
    property: 'status',
    header: {
      label: __('Installed'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [
        cell => (
          <td>
            <Icon type="pf" name={cell ? 'ok' : 'error-circle-o'} />
          </td>
        ),
      ],
    },
  },
];
