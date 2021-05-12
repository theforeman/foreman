const htmlElement = document.getElementsByTagName('html')[0];

export default {
  locales: window.locales || {},
  locale: htmlElement.getAttribute('lang') || 'en',
  timezone: htmlElement.getAttribute('data-timezone') || 'UTC',
};
