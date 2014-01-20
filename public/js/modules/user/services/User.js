angular.module('IOUApp')

    .factory('User', function($rootScope, $location, $cookieStore) {

        var login = function(userData) {
            setUserData(userData);
            $rootScope.$broadcast('login');
            $location.path('/');
        }

        var logout = function() {
            removeUserData();
            $rootScope.$broadcast('logout');
            $location.path('/splash');
        }

        var getUserData = function() {
            return $cookieStore.get('userData');
        }

        var setUserData = function (userData) {
            $cookieStore.put('userData', userData);
        }

        var removeUserData = function () {
            $cookieStore.remove('userData');
        };

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

        var isLogged = function() {
            var apiToken = getUserProperty('ioweyouToken');
            var uid = getUserProperty('ioweyouId');

            if(apiToken && uid) {
                return true;
            }

            return false;
        };

        return {
            login: login,
            logout: logout,
            setUserData: setUserData,
            removeUserData: removeUserData,
            getUserData: getUserData,
            getUserProperty: getUserProperty,
            getUserCredentials: getUserCredentials,
            isLogged: isLogged
        }


    }
);