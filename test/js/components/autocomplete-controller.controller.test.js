describe('Controller: AutocompleteController', function() {
    var controller,
        $httpBackend,
        $rootScope;

    beforeEach(module('Foreman'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        $httpBackend = $injector.get('$httpBackend');
        $rootScope = $injector.get('$rootScope');

        controller = $controller('AutocompleteController');
        controller.url = '/hosts';
    }));

    describe('that expects API calls', function () {

        afterEach(function() {
            $httpBackend.flush();
            $httpBackend.verifyNoOutstandingExpectation();
            $httpBackend.verifyNoOutstandingRequest();
        });

        it("calls the auto complete search API", function() {
            $httpBackend.expectGET('/hosts/auto_complete_search?search=')
                    .respond([]);

            controller.autocomplete('');
        });

        it("calls the auto complete search API", function() {
            $httpBackend.expectGET('/hosts/auto_complete_search?search=name+%3D+testhost')
                    .respond([]);

            controller.autocomplete('name = testhost');
        });
    });

    it("formatResults should return data formatted properly", function() {
        var data = [];

        expect(controller.formatResults(data)).toBeDefined();
    });

});
