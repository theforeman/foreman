export const spySelector = selectors => {
  jest.spyOn(selectors, 'selectToastsListState');
  jest.spyOn(selectors, 'selectToastsListMessages');

  selectors.selectToastsListState.mockImplementation(() => {});
  selectors.selectToastsListMessages.mockImplementation(
    () => [
      {
        "message": "message",
        "type": "success",
        "key": "msg_one"
      }
    ]
  );
};
