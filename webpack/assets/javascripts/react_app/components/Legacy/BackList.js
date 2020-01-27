// Add pathes (regex template) for triggering full page reload
const blackList = [/\/puppetclasses\/.+\/edit/];

export const inBlackList = path => blackList.some(item => item.test(path));
