export const noop = Function.prototype; // empty function

// open the link in a new window
export const newWindowOnClick = url => event => {
  event.preventDefault();
  window.open(url, '_blank');
};

export default {
  bindMethods(context, methods) {
    methods.forEach(method => {
      // eslint-disable-next-line no-param-reassign
      context[method] = context[method].bind(context);
    });
  },
  noop,
};
