export default {
  bindMethods: function (context, methods) {
    methods.forEach(method => {
      context[method] = context[method].bind(context);
    });
  },
  noop: Function.prototype // empty function
};
