export const getPageStats = ({ total, page, perPage }) => {
  // logic adapted from patternfly so that we can know the number of items per page
  const lastPage = Math.ceil(total / perPage) ?? 0;
  const firstIndex = total <= 0 ? 0 : (page - 1) * perPage + 1;
  let lastIndex;
  if (total <= 0) {
    lastIndex = 0;
  } else {
    lastIndex = page === lastPage ? total : page * perPage;
  }
  let pageRowCount = lastIndex - firstIndex + 1;
  if (total <= 0) pageRowCount = 0;
  return {
    firstIndex,
    lastIndex,
    pageRowCount,
    lastPage,
  };
};
