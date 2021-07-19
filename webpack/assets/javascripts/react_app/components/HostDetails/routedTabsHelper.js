// react-router uses path-to-regexp, should we use it as well?
// https://github.com/pillarjs/path-to-regexp/tree/v1.7.0#compile-reverse-path-to-regexp
const resolvePath = (path, params) =>
  Object.entries(params).reduce(
    (memo, [key, value]) => memo.replace(key, value || ''),
    path
  );

export const handleTabClick = (history, match, toReplace) => (event, value) => {
  const replaceHash = { [toReplace]: value.toLowerCase() };
  history.push(
    resolvePath(match.path, {
      ':id': match.params.id,
      ':tab?': match.params.tab,
      ':subtab?': match.params.subtab,
      ...replaceHash,
    })
  );
};
