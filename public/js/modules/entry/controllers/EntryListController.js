angular.module('IOUApp')

    .controller('EntryListController', function($scope, $http, Entry, EntryFilter, AuthFactory) {

            var queryParams = {};

            $scope.filter = {};

            $scope.statuses = EntryFilter.getStatuses();

            $scope.userData = AuthFactory.getUserData();

            $scope.updateQueryParams = function() {
                EntryFilter.addFilter(queryParams, 'limit', $scope.limit);
                EntryFilter.addFilter(queryParams, 'offset', $scope.offset());
                EntryFilter.addFilter(queryParams, 'status', $scope.filter.status);
                EntryFilter.addFilter(queryParams, 'name', $scope.filter.name);
                EntryFilter.addTimestampFilter(queryParams, 'from', $scope.filter.from);
                EntryFilter.addTimestampFilter(queryParams, 'to', $scope.filter.to, 86399000);
            }

            $scope.fetchNumberOfEntries = function() {
                Entry.count(queryParams)
                    .success(function(result) {
                        $scope.nbOfEntries = result.aggregate;
                    });
            }

            $scope.fetchEntries = function() {
                Entry.get(queryParams)
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
                $scope.fetchEntries();
            }

            $scope.nextPage = function() {
                $scope.page++;
                $scope.fetchEntries();
            }

            $scope.page = 0;
            $scope.limit = 8;


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


