// to avoid webpack alias loop
const jquery = require('../../../node_modules/jquery');

window.$ = jquery;
window.jQuery = jquery;
window.jquery = jquery;

module.exports = jquery;

require('jquery.cookie');
require('jquery-ujs');
require('multiselect');
require('select2');
require('datatables.net-bs');
require('dsmorse-gridster/dist/jquery.dsmorse-gridster');
