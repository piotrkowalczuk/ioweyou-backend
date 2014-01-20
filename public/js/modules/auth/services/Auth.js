angular.module('IOUApp')

    .factory('Auth', function($http) {
        var login = function(credentials) {
            return $http.post('/api/login', credentials);
        };

        return {
            login : login
        }


    }
);