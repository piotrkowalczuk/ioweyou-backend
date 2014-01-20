angular.module('IOUApp').factory('HttpResponseInterceptor',
    function($q, User){
        return {
            'responseError': function(rejection) {
                if(rejection.status === 403) {
                    User.logout();
                    return rejection;
                }

                return $q.reject(rejection);
            }
        }
    }
);