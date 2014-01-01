angular.module('IOUApp')

    .controller('EntryListController', ['$scope', '$http', 'EntryFactory', 'AuthFactory',
        function($scope, $http, EntryFactory, AuthFactory) {

            $scope.userData = AuthFactory.getUserData();

            $scope.fetchNumberOfEntries = function() {
                EntryFactory.count()
                    .success(function(result) {
                        $scope.nbOfEntries = result.aggregate;
                    });
            }

            $scope.fetchEntries = function() {
                filters = {
                    limit: $scope.limit,
                    offset: $scope.offset(),
                    status: $scope.status
                }
                EntryFactory.get(filters)
                    .success(function(entries) {
                        $scope.entries = entries;
                    });
                $scope.fetchNumberOfEntries();
            }

            $scope.getStatus = function(statusId) {
                return EntryFactory.getStatus(statusId);
            }

            $scope.prevPage = function() {
                $scope.page--;
                $scope.fetchEntries();
            }

            $scope.nextPage = function() {
                $scope.page++;
                $scope.fetchEntries();
            }

            $scope.page = 1;
            $scope.limit = 8;
            $scope.offset = function() {
                return $scope.page * 8;
            };
            $scope.status = null;
            $scope.nbOfPages = function() {
                var tmp = $scope.nbOfEntries / $scope.limit;
                return Math.ceil(tmp * 10) / 10;
            };
            $scope.fetchEntries();
        }
    ]);


