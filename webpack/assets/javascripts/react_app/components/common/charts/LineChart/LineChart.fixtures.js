export const data = [
  ['red', [5, 7, 9], '#AA4643'],
  ['green', [2, 4, 6], '#89A54E'],
];

const createDate = (year, month, day) => new Date(year, month, day).getTime();

export const timeseriesData = [
  ...data,
  [
    'x',
    [createDate(2019, 4, 5), createDate(2019, 5, 6), createDate(2019, 6, 7)],
    null,
  ],
];
