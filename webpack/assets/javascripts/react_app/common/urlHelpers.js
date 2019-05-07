/**
 * Build a url from given controller, action and id
 * @param {String} controller - the controller
 * @param {String} action - the action
 */
export const urlBuilder = (controller, action, id = undefined) =>
  `/${controller}/${id ? `${id}/` : ''}${action}`;

/**
 * Build a url with search query
 * @param {String} base - the base url
 * @param {String} searchQuery - the search query
 */
export const urlWithSearch = (base, searchQuery) =>
  `/${base}?search=${searchQuery}`;
