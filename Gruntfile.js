var requireDir = require('require-dir'),
    path = require('path');

module.exports = function (grunt) {
    var configs = requireDir('./grunt');

    grunt.loadTasks(path.join(__dirname, '/node_modules/grunt-eslint/tasks'));
    grunt.loadTasks(path.join(__dirname, '/node_modules/grunt-karma/tasks'));

    grunt.initConfig(configs);

    grunt.registerTask('ci', [
        'eslint',
        'karma:ci'
    ]);

    grunt.registerTask('test', [
        'karma:unit'
    ]);

    grunt.registerTask('default', [
        'ci'
    ]);
};
