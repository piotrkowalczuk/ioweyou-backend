angular.module('IOUApp')

    .controller('DashboardController', function($scope, Entry, User) {

            $scope.fetchEntries = function(status) {
                Entry.get({limit: 5, status: status})
                    .success(function(entries) {
                        $scope.entries = entries;
                    });
            }

            $scope.userData = User.getUserData();

            $scope.fetchEntries(0);

            $scope.getStatus = function(statusId) {
                return Entry.getStatus(statusId);
            }

            $scope.fetchOpenEntries = function() {
                $scope.fetchEntries(0);
            }

            $scope.fetchClosedEntries = function() {
                $scope.fetchEntries(1);
            }

            $scope.fetchRejectedEntries = function() {
                $scope.fetchEntries(2);
            }

        }
    );
