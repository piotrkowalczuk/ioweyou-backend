angular.module('IOUApp')

    .factory('EntryFactory', function($http, AuthFactory) {

        var credentials = AuthFactory.getUserCredentials;

        var status = ['otwarte', 'zamknięte', 'odrzucone', 'usunięte'];

        return {
            get : function(params) {
                params = params || {};
                params.apiToken = credentials().apiToken;
                params.uid = credentials().uid;

                return $http.get('/api/entry',{
                    params: params
                });
            },
            getOne : function(id) {
                return $http.get('/api/entry/' + id, {
                    params: credentials()
                });
            },
            count : function() {
                return $http.get('/api/entry/count', {
                    params: credentials()
                });
            },
            create : function(entry) {
                entry.apiToken = credentials().apiToken;
                entry.uid = credentials().uid;

                return $http.post('/api/entry', entry);
            },
            delete : function(id) {
                return $http.delete('/api/entry/' + id, {
                    params: credentials()
                });
            },
            getSummary : function() {
                return $http.get('/api/entry/summary', {
                    params: credentials()
                });
            },
            getStatus: function(statusId) {
                return status[statusId];
            }
        }
    });