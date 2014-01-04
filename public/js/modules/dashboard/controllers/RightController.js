angular.module('IOUApp')

    .controller('RightController', function($scope, Entry) {

            Entry.getSummary()
                .success(function(response){
                    $scope.summary = response.summary;
                });
        }
    );
