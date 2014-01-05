angular.module('IOUApp').directive('ngSrcError', function() {
    return {
        link: function(scope, element, attrs) {

            scope.$watch(function() {
                return attrs['ngSrc'];
            }, function (value) {
                if (!value) {
                    element.attr('src', attrs.ngSrcError);
                }
            });

            element.bind('error', function() {
                element.attr('src', attrs.ngSrcError);
            });
        }
    }
});