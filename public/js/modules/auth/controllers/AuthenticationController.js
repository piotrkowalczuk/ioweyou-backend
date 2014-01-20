angular.module('IOUApp')

    .controller('AuthenticationController', function AuthenticationController($scope, $FB, $location, Auth, User) {

        $scope.isCollapsed = true;

        $scope.login = function () {
            $FB.login(function (res) {
                if (res.authResponse) {
                    var accessToken = res.authResponse.accessToken;
                    Auth.login({pass: accessToken})
                        .success(function(userData) {
                            User.setUserData(userData);
                            $scope.$emit('login');
                            $location.path('/');
                        });
                }
            }, {scope: 'email,user_likes'});
        };

        $scope.logout = function () {
            $FB.logout(function () {
                User.logout();
            });
        };

        $scope.isLoggedIn = function () {
            return User.isLogged();
        }

        $scope.isActiveRoute = function(route) {
            if($location.path() === route) {
                return 'active'
            }
        }
    }
);