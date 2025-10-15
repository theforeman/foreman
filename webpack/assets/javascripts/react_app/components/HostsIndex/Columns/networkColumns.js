const networkColumns = [
  {
    columnName: 'ip',
    title: 'IPv4',
    wrapper: hostDetails => hostDetails?.ip,
    isSorted: true,
    weight: 700,
  },
  {
    columnName: 'ip6',
    title: 'IPv6',
    wrapper: hostDetails => hostDetails?.ip6,
    isSorted: true,
    weight: 800,
  },
  {
    columnName: 'mac',
    title: 'MAC',
    wrapper: hostDetails => hostDetails?.mac,
    isSorted: true,
    weight: 900,
  },
];

networkColumns.forEach(column => {
  column.tableName = 'hosts';
  column.categoryName = 'Network';
  column.categoryKey = 'network';
});

export default networkColumns;
