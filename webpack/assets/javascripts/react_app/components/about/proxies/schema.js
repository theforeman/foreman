import React from 'react';
import ConnectedStatus from '../../common/status';
import { headerFormat, ellipsisFormat } from '../../common/table';
import helpers from '../../../common/helpers';

export const columns = () => [
  {
    property: 'id',
    header: {
      label: __('Name'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [
        value => (
            <td>
              <a href={helpers.urlBuilder('smart_proxies', '', value.id)}>
                {value.name}
              </a>
            </td>
        ),
      ],
    },
  },
  {
    property: 'features',
    header: {
      label: __('Features'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [ellipsisFormat],
    },
  },
  {
    property: 'id',
    header: {
      label: __('Status'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [
        value => (
            <td id={`proxy${value.id}_status`}>
              <ConnectedStatus
                data={{
                  type: 'smart_proxy',
                  id: value.id,
                  url: helpers.urlBuilder('smart_proxies', 'ping', value.id),
                }}
              />
            </td>
        ),
      ],
    },
  },
  {
    property: 'id',
    header: {
      label: __('Version'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [
        value => (
            <td id={`proxy${value.id}_version`}>
              <ConnectedStatus getMessage='version'
                data={{
                  type: 'smart_proxy',
                  id: value.id,
                }}
              />
            </td>
        ),
      ],
    },
  },
];
