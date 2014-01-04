angular.module('IOUApp')

    .controller('EntryListController', function($scope, $http, Entry, EntryFilter, AuthFactory) {

            $scope.filter = {};
            $scope.filters = {};
            $scope.statuses = EntryFilter.getStatuses();

            $scope.userData = AuthFactory.getUserData();

            $scope.fetchNumberOfEntries = function(filters) {
                Entry.count(filters)
                    .success(function(result) {
                        $scope.nbOfEntries = result.aggregate;
                    });
            }

            getTimestamp = function(date){
                if(date instanceof Date) {
                    return date.getTime();
                }
                return null;
            }
            $scope.fetchEntries = function() {
                var filters = {};

                EntryFilter.addFilter(filters, 'limit', $scope.limit);
                EntryFilter.addFilter(filters, 'offset', $scope.offset());
                EntryFilter.addFilter(filters, 'status', $scope.filter.status);
                EntryFilter.addFilter(filters, 'name', $scope.filter.name);
                EntryFilter.addTimestampFilter(filters, 'from', $scope.filter.from);
                EntryFilter.addTimestampFilter(filters, 'to', $scope.filter.to, 86399000);

                Entry.get(filters)
                    .success(function(entries) {
                        $scope.entries = entries;
                    });
                $scope.fetchNumberOfEntries(filters);
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
        }
    );


