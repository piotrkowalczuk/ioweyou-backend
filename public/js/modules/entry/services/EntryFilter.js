angular.module('IOUApp')

    .factory('EntryFilter', function($http) {

        var statuses = ['Otwarte', 'Zaakceptowane', 'Odrzucone'];

        var getStatuses = function(statusId) {
            return statuses
        }
        var addFilter = function(filter, name, value) {
            if(typeof value != 'undefined') {
                filter[name] = value;
            }
        }
        var addTimestampFilter = function(filter, name, date, extraTimestamp) {
            if(date instanceof Date) {
                filter[name] = date.getTime() + Number(extraTimestamp||0);
            }
        }

        return {
            addTimestampFilter : addTimestampFilter,
            addFilter: addFilter,
            addTimestampFilter: addTimestampFilter,
            getStatuses: getStatuses
        }
    });