var basePath = __dirname + '/../',
    pluginName = process.cwd().split('/').pop();


module.exports = {
    options: {
        frameworks: ['jasmine'],
        runnerPort: 9100,
        colors: true,
        browsers: ['PhantomJS'],
        reporters: ['progress'],
        singleRun: true,
        preprocessors: {
            'app/assets/javascripts/**/*.html': ['ng-html2js']
        },
        files: [
            basePath + '.tmp/bower_components/jquery/jquery.js',
            basePath + '.tmp/bower_components/underscore/underscore.js',
            basePath + '.tmp/bower_components/angular/angular.js',
            basePath + '.tmp/bower_components/angular-bootstrap/ui-bootstrap.js',
            basePath + '.tmp/bower_components/angular-bootstrap/ui-bootstrap-tpls.js',
            basePath + '.tmp/bower_components/angular-mocks/angular-mocks.js',

            basePath + 'app/assets/javascripts/components/foreman.module.js',
            basePath + 'app/assets/javascripts/components/**/*.js',
            'test/js/**/*.js'
        ],
        ngHtml2JsPreprocessor: {
            cacheIdFromPath: function (filepath) {
                return filepath.replace(/app\/assets\/javascripts\/bastion\w*\//, '');
            }
        }
    },
    server: {
        autoWatch: true
    },
    unit: {
        singleRun: true
    },
    ci: {
        reporters: ['progress', 'coverage'],
        preprocessors: {
            'app/assets/javascripts/**/*.js': ['coverage']
        },
        coverageReporter: {
            type: 'cobertura',
            dir: 'coverage/'
        }
    }
}

