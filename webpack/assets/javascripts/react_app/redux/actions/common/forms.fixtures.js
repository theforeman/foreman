export const requestData = {
  headers: {},
  item: 'Resource',
  url: '/api/resource',
  values: { a: 1 },
  customErrorAlert: () => {
    return 'Value should not be blank';
  },
};

export const requestDataMsg = Object.assign({}, requestData, {
  message: 'Customized success!',
});
