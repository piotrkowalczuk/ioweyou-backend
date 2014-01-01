angular.module('IOUApp')

    .controller('DashboardController', ['$scope', 'EntryFactory', 'AuthFactory',
        function($scope, EntryFactory, AuthFactory) {

            $scope.fetchEntries = function(status) {
                EntryFactory.get({limit: 5, status: status})
                    .success(function(entries) {
                        $scope.entries = entries;
                    });
            }

            $scope.userData = AuthFactory.getUserData();

            $scope.fetchEntries(0);


            $scope.getStatus = function(statusId) {
                return EntryFactory.getStatus(statusId);
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
    ]);
