angular.module('IOUApp').factory('HttpResponseInterceptor',
    function($q, $location){
        return {
            'responseError': function(response) {
                $location.path('/splash');
                return response;
            }
        }
    }
);