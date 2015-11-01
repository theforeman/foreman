(function () {

    /**
     * @ngdoc directive
     * @name Foreman.directive:tfmTypeaheadEmpty
     *
     *
     * @description
     *  Used to support autocompletion on focus, not just after the user types a single character
     *
     * @example
        <input typeahead="item as item.label for item in table.autocomplete($viewValue)"
               tfm-typeahead-empty />
     */
    function tfmTypeaheadEmpty() {
        return {
            require: 'ngModel',
            link: function (scope, element, attrs, modelCtrl) {
                element.bind('focus', function () {
                    if (angular.isUndefined(modelCtrl.$viewValue) || modelCtrl.$viewValue === '') {
                        modelCtrl.$setViewValue(' ');
                    } else {
                        modelCtrl.$setViewValue(modelCtrl.$viewValue);
                    }
                });
            }
        };
    }

    angular
        .module('Foreman')
        .directive('tfmTypeaheadEmpty', tfmTypeaheadEmpty);

})();
