// eslint-disable-next-line import/prefer-default-export
export const stringIncludes = (string, includes) => {
  const a = string.replace(/\s/g, '').toLowerCase();
  const b = includes.replace(/\s/g, '').toLowerCase();
  return a.includes(b);
};
