angular.module('IOUApp')

    .factory('Entry', function($http, User) {

        var credentials = User.getUserCredentials;

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
            count : function(params) {
                params = params || {};
                params.apiToken = credentials().apiToken;
                params.uid = credentials().uid;

                return $http.get('/api/entry/count', {
                    params: params
                });
            },
            create : function(entry) {
                entry.apiToken = credentials().apiToken;
                entry.uid = credentials().uid;

                return $http.put('/api/entry', entry);
            },
            modify : function(entryId, data) {
                data.apiToken = credentials().apiToken;
                data.uid = credentials().uid;

                return $http.post('/api/entry/'+entryId, data);
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
            getSummary : function(params) {
                params = params || {};
                params.apiToken = credentials().apiToken;
                params.uid = credentials().uid;

                return $http.get('/api/entry/summary', {
                    params: params
                });
            },
            getStatus: function(statusId) {
                return status[statusId];
            }
        }
    });