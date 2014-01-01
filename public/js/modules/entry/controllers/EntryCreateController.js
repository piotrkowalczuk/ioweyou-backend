angular.module('IOUApp')

    .controller('EntryCreateController', ['$scope', 'EntryFactory', 'UserFactory',
        function($scope, EntryFactory, UserFactory) {

            UserFactory.getFriends()
                .success(function(friends){
                    $scope.friends = friends;
                });

            $scope.createEntry = function() {

                if (!$.isEmptyObject($scope.formData)) {

                    EntryFactory.create($scope.formData)
                        .success(function(data) {
                            $scope.formData = {};
                            $scope.entries = data;
                        });
                }
            };
        }
     ]);
