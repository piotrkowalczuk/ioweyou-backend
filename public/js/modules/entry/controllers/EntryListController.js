angular.module('IOUApp')

    .controller('EntryListController',
        function($scope, $http, Entry, EntryFilter, AuthFactory, UserFactory) {
            $scope.page = 0;

            $scope.limit = 8;

            $scope.queryParams = {};

            $scope.filter = {};

            $scope.statuses = EntryFilter.getStatuses();

            $scope.userData = AuthFactory.getUserData();

            UserFactory.getFriends()
                .success(function(friends){
                    $scope.contractors = friends;
                });

            $scope.updateQueryParams = function() {
                var offset = $scope.offset();

                EntryFilter.addFilter($scope.queryParams, 'limit', $scope.limit);
                EntryFilter.addFilter($scope.queryParams, 'offset', offset);
                EntryFilter.addFilter($scope.queryParams, 'status', $scope.filter.status);
                EntryFilter.addFilter($scope.queryParams, 'name', $scope.filter.name);
                EntryFilter.addFilter($scope.queryParams, 'contractor', $scope.filter.contractor);
                EntryFilter.addTimestampFilter($scope.queryParams, 'from', $scope.filter.from);
                EntryFilter.addTimestampFilter($scope.queryParams, 'to', $scope.filter.to, 86399000);
                console.log($scope.queryParams);
            }

            $scope.fetchNumberOfEntries = function() {
                Entry.count($scope.queryParams)
                    .success(function(result) {
                        $scope.nbOfEntries = result.aggregate;
                    });
            }

            $scope.fetchEntries = function() {
                Entry.get($scope.queryParams)
                    .success(function(entries) {
                        $scope.entries = entries;
                    });
            }

            $scope.fetchData = function() {
                $scope.page = 0;
                $scope.updateQueryParams();
                $scope.fetchEntries();
                $scope.fetchNumberOfEntries();
            }

            $scope.getStatus = function(statusId) {
                return Entry.getStatus(statusId);
            }

            $scope.prevPage = function() {
                $scope.page--;
                $scope.updateQueryParams();
                $scope.fetchEntries();
            }

            $scope.nextPage = function() {
                $scope.page++;
                $scope.updateQueryParams();
                $scope.fetchEntries();
            }

            $scope.offset = function() {
                return $scope.page * 8;
            };
            $scope.nbOfPages = function() {
                var tmp = $scope.nbOfEntries / $scope.limit;
                return Math.ceil(tmp * 10) / 10;
            };

            $scope.fetchEntries();
            $scope.fetchNumberOfEntries();
        }
    );


