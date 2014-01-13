angular.module('IOUApp')

    .controller('AuthenticationController', ['$scope', '$FB', '$location', 'AuthFactory',
        function AuthenticationController($scope, $FB, $location, AuthFactory) {

            $scope.isCollapsed = true;

            $scope.login = function () {
                $FB.login(function (res) {
                    if (res.authResponse) {
                        var accessToken = res.authResponse.accessToken;
                        AuthFactory.login({pass: accessToken})
                            .success(function(userData) {
                                AuthFactory.setUserData(userData);
                                $location.path('/');
                            });
                    }
                }, {scope: 'email,user_likes'});
            };

            $scope.logout = function () {
                $FB.logout(function () {
                    AuthFactory.removeUserData();
                    $location.path('/splash');
                });
            };

            $scope.isLoggedIn = function () {
                return AuthFactory.isLogged();
            }

            $scope.isActiveRoute = function(route) {
                if($location.path() === route) {
                    return 'active'
                }
            }
}]);