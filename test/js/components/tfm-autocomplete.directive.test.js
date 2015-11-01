describe('Directive: tfmAutocomplete', function() {
    var scope,
        compile,
        element,
        elementScope;

    beforeEach(module(
        'Foreman'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        element = angular.element('<input tfm-autocomplete="/hosts"/>');

        compile(element)(scope);
        scope.$digest();

        elementScope = element.isolateScope();
    });

    it("should be an input", function() {
        expect(element.find('input').length).toBe(1);
    });

    it("should contain directive uib-typeahead", function() {
        expect(element.find('[uib-typeahead]').length).toBe(1);
    });

    it("should have an input with name search", function() {
        expect(element.find('[name="search"]').length).toBe(1);
    });

    it("should use typeahead-empty for handling initially empty input", function() {
        expect(element.find('[tfm-typeahead-empty=""]').length).toBe(1);
    });
});
