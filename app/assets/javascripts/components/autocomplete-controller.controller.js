(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Foreman.controller:AutocompleteController
     *
     * @description
     *   Handles retrieving autocomplete data.
     */
    function AutocompleteController($http) {
        var self = this;

        self.formatResults = function(results) {
            var rows = [],
                categoriesFound = [];

            angular.forEach(results, function (row) {
                if (row.category && row.category.length > 0) {
                    if (categoriesFound.indexOf(row.category) === -1) {
                        categoriesFound.push(row.category);
                        rows.push({category: row.category, isCategory: true});
                    }
                }
                rows.push(row);
            });

            return rows;
        };

        self.autocomplete = function (term) {
            var promise;

            promise = $http.get(
                self.url + '/auto_complete_search',
                {params: {search: term}}
            ).then(function (response) {
                return self.formatResults(response.data);
            });

            return promise;
        };
    }


    angular
        .module('Foreman')
        .controller('AutocompleteController', AutocompleteController);

    AutocompleteController.$inject = ['$http'];

})();
