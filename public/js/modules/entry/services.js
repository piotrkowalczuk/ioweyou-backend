angular.module('IOUApp')

    .factory('EntryFactory', function($http, AuthFactory) {

        var credentials = AuthFactory.getUserCredentials;

        var status = ['Otwarte', 'Zaakceptowane', 'Odrzucone', 'Usunięte'];

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
            accept : function(id) {
                return $http.post('/api/entry/accept/' + id, credentials());
            },
            reject : function(id) {
                return $http.post('/api/entry/reject/' + id, credentials());
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