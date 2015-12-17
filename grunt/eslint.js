module.exports = {
    options: {
        configFile: __dirname + '/../eslint.yaml',
        quiet: true
    },
    target: [
        'Gruntfile.js',
        'app/assets/javascripts/components/**/*.js',
    ]
};
