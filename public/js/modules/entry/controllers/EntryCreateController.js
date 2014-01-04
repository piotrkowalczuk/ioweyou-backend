angular.module('IOUApp')

    .controller('EntryCreateController', function($scope, $location, Entry, UserFactory) {

            $scope.buttonSave = {
                label: 'Zapisz',
                disabled: false
            }

            $scope.entry = {
                contractors: [],
                includeMe: 0
            };

            $scope.formErrors = {};

            UserFactory.getFriends()
                .success(function(friends){
                    $scope.friends = friends;
                });

            $scope.createEntry = function() {
                $scope.buttonSave.label = 'Przetwarzanie...';
                $scope.buttonSave.disabled = true;

                Entry.create($scope.entry)
                    .success(function(data) {
                        if(data.isCreated) {
                            $scope.$emit('flashMessage', 'success', 'Wpis został utworzony poprawnie.');
                            $location.path('/');
                        } else {
                            $scope.$emit('flashMessage', 'danger', 'Żądanie zostało wysłane porpawnie, jednak wpis nie został utworzony. Spróbuj ponownie.');
                            $scope.buttonSave.label = 'Zmień';
                            $scope.buttonSave.disabled = false;
                        }
                    }).error(function(errors) {
                        $scope.formErrors = errors;
                        $scope.buttonSave.label = 'Zmień';
                        $scope.buttonSave.disabled = false;
                    });

            };

            $scope.toggleContractors = function toggleContractors(contractorId) {
                var idx = $scope.entry.contractors.indexOf(contractorId);

                if (idx > -1) {
                    $scope.entry.contractors.splice(idx, 1);
                } else {
                    $scope.entry.contractors.push(contractorId);
                }
            };

            $scope.hasError = function hasError(fieldName) {
                if($scope.formErrors[fieldName]) {
                    return true;
                }

                return false;
            }
        }
    );
