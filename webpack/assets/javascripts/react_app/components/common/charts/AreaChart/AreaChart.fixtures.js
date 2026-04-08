export const areaChartData = {
  yAxisLabel: "Number of Hosts",
  data: [
    ["time", 1614449768, 1614451500],
    ["CentOS 7.9", 3, 5],
    ["CentOS 7.6", 2, 1],
    ["Fedora 32", 1, 2]
  ]
};

/** Data with multiple points within the same minute - used to test that x-axis
 * does not show duplicate date labels (regression test for double timestamps). */
export const areaChartDataDenseSameMinute = {
  yAxisLabel: "Reports",
  data: [
    [
      "time",
      1614449760, // Mar 3, 9:44 AM
      1614449770, // +10s
      1614449780, // +20s
      1614449790, // +30s
      1614449800, // +40s
      1614449810, // +50s
      1614449820, // +60s (next minute)
      1614449880, // +2 min
      1614449940, // +3 min
      1614450000, // +4 min
    ],
    ["Config Retrieval", 1, 2, 1, 3, 2, 1, 2, 3, 1, 2],
    ["Runtime", 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
  ],
};
