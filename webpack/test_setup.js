/* eslint-disable func-names */
jest.mock('jed');
jest.mock('./assets/javascripts/react_app/common/I18n');
jest.mock('./assets/javascripts/foreman_tools', () => ({
  foremanUrl: url => url,
}));
global.Range = function Range() {};
const createContextualFragment = html => {
  const div = document.createElement('div');
  div.innerHTML = html;
  return div.children[0];
};
Range.prototype.createContextualFragment = html =>
  createContextualFragment(html);
global.window.URL.createObjectURL = function() {};
global.window.focus = () => {};
// HACK: Polyfill that allows codemirror to render in a JSDOM env.
global.window.document.createRange = function createRange() {
  return {
    setEnd: () => {},
    setStart: () => {},
    getBoundingClientRect: () => ({ right: 0 }),
    getClientRects: () => [],
    createContextualFragment,
  };
};
