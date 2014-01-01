angular.module('IOUApp')

    .factory('AuthFactory', ['$http', '$cookieStore', function($http, $cookieStore) {
        var login = function(credentials) {
            return $http.post('/api/login', credentials);
        };

        var getUserData = function() {
            return $cookieStore.get('userData');
        }

        var setUserData = function (userData) {
            $cookieStore.put('userData', userData);
        }

        var getUserProperty = function(property) {
            var userData = getUserData();

            if(userData) {
                return userData[property];
            }

            return null;
        };

        var getUserCredentials = function() {
            var credentials = {
                apiToken: getUserProperty('ioweyouToken'),
                uid: getUserProperty('ioweyouId')
            };

            return credentials;
        };

        var removeUserData = function () {
            $cookieStore.remove('userData');
        };

        var isLogged = function() {
            var apiToken = getUserProperty('ioweyouToken');
            var uid = getUserProperty('ioweyouId');

            if(apiToken && uid) {
                return true;
            }
            return false;
        };

        return {
            login : login,
            setUserData: setUserData,
            removeUserData: removeUserData,
            getUserData: getUserData,
            getUserProperty: getUserProperty,
            getUserCredentials: getUserCredentials,
            isLogged: isLogged
        }


    }]);