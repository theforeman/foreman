export const getSortColumnIndex = (columns, sortBy) => {
  let colIndex = 0;
  columns.forEach((col, index) => {
    if (col.sortKey === sortBy) {
      colIndex = index;
    }
  });
  return colIndex;
};

export const getPerPageOptions = (urlPerPage, appPerPage) => {
  const initialValues = new Set([5, 10, 15, 25, 50]);
  initialValues.add(appPerPage);
  urlPerPage && initialValues.add(urlPerPage);
  const options = [...initialValues].sort((a, b) => a - b);
  return options.map(value => ({ title: value.toString(), value }));
};

export const getTableAPIKey = path => `TABLE${path}`;
