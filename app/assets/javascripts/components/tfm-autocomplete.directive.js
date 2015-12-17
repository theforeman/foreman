(function () {
    'use strict';

    /**
     * @ngdoc directive
     * @name  Foreman.directive:tfmAutocomplete
     *
     * @description
     *   Configures typahead directive based on autcomplete result format.
     *
     * @example
     *   <input tfm-autocomplete="/hosts" search="fakeSearch"/>
     */
    function tfmAutocomplete() {
        var template = [
            '<span>',
                '<script type="text/ng-template" id="autocomplete-scoped-search.html">',
                    '<i class="ui-autocomplete-category" ng-show="match.model.isCategory">',
                        '{{ match.model.category }}',
                    '</i>',

                    '<a ng-hide="match.model.isCategory">',
                        '<i class="ui-autocomplete-completed">',
                            '{{ match.model.completed }}',
                        '</i>',
                        '{{ match.model.part }}',
                    '</a>',
                '</script>',
                '<input class="form-control"',
                        'type="text"',
                        'name="search"',
                        'placeholder="Search..."',
                        'ng-model="autocomplete.selected"',
                        'ng-trim="false"',
                        'uib-typeahead="item.label for item in autocomplete.autocomplete($viewValue)"',
                        'tfm-typeahead-empty=""',
                        'typeahead-template-url="autocomplete-scoped-search.html"/>',
                '<span>'
            ];

        return {
            scope: {
                url: '@tfmAutocomplete',
                selected: '@search'
            },
            restrict: 'EA',
            replace: true,
            controllerAs: 'autocomplete',
            bindToController: true,
            controller: 'AutocompleteController',
            template: template.join('')
        };
    }

    angular
        .module('Foreman')
        .directive('tfmAutocomplete', tfmAutocomplete);

})();
