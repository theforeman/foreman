export const currentTab = (location, level)=> {
  if (!location.hash) {
    return ''
  }
  return location.hash.replace('#', '').split('-')[level]
}

export const handleTabClick = (history, level) => (event, value) => {
  const split = history.location.hash.split('-');
  split[level] = value;
  const newHash = split.slice(0, level + 1).join('-');
  history.push({ pathname: history.location.pathname, hash: `${newHash}` })
}
