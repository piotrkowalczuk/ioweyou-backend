angular.module('IOUApp')

    .controller('RightController', ['$scope', 'EntryFactory',
        function($scope, EntryFactory) {

            EntryFactory.getSummary()
                .success(function(response){
                    $scope.summary = response.summary;
                });
        }
    ]);
