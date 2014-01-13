angular.module('IOUApp').controller('NavbarController',
    function NavbarController( $scope, AuthFactory ) {
        'use strict';
        $scope.first_name = AuthFactory.getUserProperty('first_name');
        $scope.last_name = AuthFactory.getUserProperty('last_name');
        $scope.username = AuthFactory.getUserProperty('username');
        $scope.userId = AuthFactory.getUserProperty('ioweyouId');
    }
);