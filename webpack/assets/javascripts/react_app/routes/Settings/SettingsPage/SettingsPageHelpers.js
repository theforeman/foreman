export const demodulize = title => title.split('::')[1];

export const stickCategory = sticky => categories =>
  categories.includes(sticky)
    ? [sticky, ...categories.filter(item => item !== sticky)]
    : categories;

export const stickGeneralFirst = stickCategory('Setting::General');

export const groupSettings = settings =>
  settings.reduce((memo, setting) => {
    if (!memo[setting.category]) {
      memo[setting.category] = [setting];
      return memo;
    }
    memo[setting.category].push(setting);
    return memo;
  }, {});
