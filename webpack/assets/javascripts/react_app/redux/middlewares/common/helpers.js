export const amendActionsPayload = (action, extPayload) => ({
  ...action,
  payload: {
    ...action.payload,
    ...extPayload,
  },
});
