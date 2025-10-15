/* eslint-disable camelcase */
import { number_to_human_size as NumberToHumanSize } from 'number_helpers';
import { translate as __ } from '../../../common/I18n';

const reportedDataColumns = [
  {
    columnName: 'model',
    title: __('Model'),
    wrapper: hostDetails =>
      hostDetails?.compute_resource_name || hostDetails?.model_name,
    isSorted: true,
    weight: 1000,
  },
  {
    columnName: 'sockets',
    title: __('Sockets'),
    wrapper: hostDetails => hostDetails?.reported_data?.sockets,
    isSorted: false,
    weight: 1100,
  },
  {
    columnName: 'cores',
    title: __('Cores'),
    wrapper: hostDetails => hostDetails?.reported_data?.cores,
    isSorted: false,
    weight: 1200,
  },
  {
    columnName: 'ram',
    title: __('RAM'),
    wrapper: hostDetails => {
      if (!hostDetails?.reported_data?.ram) return null;
      return NumberToHumanSize(hostDetails.reported_data.ram * 1024 * 1024, {
        strip_insignificant_zeros: true,
      });
    },
    isSorted: false,
    weight: 1300,
  },
  {
    columnName: 'virtual',
    title: __('Virtual'),
    wrapper: hostDetails => {
      const value = hostDetails?.reported_data?.virtual;
      if (value === undefined || value === null) {
        return '';
      }
      return value ? __('Virtual') : __('Physical');
    },
    isSorted: false,
    weight: 1400,
  },
  {
    columnName: 'disks_total',
    title: __('Total disk space'),
    wrapper: hostDetails => {
      if (!hostDetails?.reported_data?.disks_total) return null;
      return NumberToHumanSize(hostDetails.reported_data.disks_total, {
        strip_insignificant_zeros: true,
      });
    },
    isSorted: false,
    weight: 1500,
  },
  {
    columnName: 'kernel_version',
    title: __('Kernel version'),
    wrapper: hostDetails => hostDetails?.reported_data?.kernel_version,
    isSorted: false,
    weight: 1600,
  },
  {
    columnName: 'bios_vendor',
    title: __('BIOS vendor'),
    wrapper: hostDetails => hostDetails?.reported_data?.bios_vendor,
    isSorted: false,
    weight: 1700,
  },
  {
    columnName: 'bios_release_date',
    title: __('BIOS release date'),
    wrapper: hostDetails => hostDetails?.reported_data?.bios_release_date,
    isSorted: false,
    weight: 1800,
  },
  {
    columnName: 'bios_version',
    title: __('BIOS version'),
    wrapper: hostDetails => hostDetails?.reported_data?.bios_version,
    isSorted: false,
    weight: 1900,
  },
];

reportedDataColumns.forEach(column => {
  column.tableName = 'hosts';
  column.categoryName = 'Reported data';
  column.categoryKey = 'reported_data';
});

export default reportedDataColumns;
