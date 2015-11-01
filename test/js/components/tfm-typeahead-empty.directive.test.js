describe('Directive: tfmTypeaheadEmpty', function() {
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
        element = angular.element('<input ng-model="myInput" type="text" tfm-typeahead-empty/>');

        compile(element)(scope);
        scope.$digest();

        elementScope = element.isolateScope();
    });

    it("should adjust empty string", function() {
        scope.myInput = '';
        scope.$digest();
        element.triggerHandler('focus');

        expect(scope.myInput).toBe(' ');
    });

    it("should adjust undefined", function() {
        scope.myInput = undefined;
        scope.$digest();
        element.triggerHandler('focus');

        expect(scope.myInput).toBe(' ');
    });

    it("should not adjust otherss", function() {
        scope.myInput = 'foo';
        scope.$digest();
        element.triggerHandler('focus');

        expect(scope.myInput).toBe('foo');
    });
});
