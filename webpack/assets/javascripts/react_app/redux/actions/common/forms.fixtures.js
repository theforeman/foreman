export const requestData = {
  values: { a: 1 },
  url: '/api/resource',
  item: 'Resource',
};

export const requestDataMsg = Object.assign({}, requestData, {
  message: 'Customized success!',
});
