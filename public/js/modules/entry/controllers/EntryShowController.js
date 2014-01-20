angular.module('IOUApp')

    .controller('EntryShowController',
    function($scope, $routeParams, $location, Entry, User) {
        $scope.userData = User.getUserData();
        $scope.entry = {};
        $scope.formData = {};
        $scope.formErrors = {};
        $scope.formVisibility = false;

        $scope.buttonSave = {
            label: 'Zmień',
            disabled: false
        }

        $scope.form = {
            from: {
                open: false
            },
            to: {
                open: false
            }
        }

        var fetchEntry = function() {

            Entry.getOne($routeParams.id)
                .success(function(entry) {
                    $scope.entry = entry;

                    $scope.formData = angular.copy(entry);

                    $scope.isOpen = isOpen();

                    $scope.isAccepted = isAccepted();

                    $scope.isRejected = isRejected();

                    $scope.isDeleted = isDeleted();

                    $scope.isEditable = isEditable();

                    $scope.isAcceptable = isAcceptable();

                    $scope.isRejectable = isRejectable();

                    $scope.isDeletable = isDeletable();

                    $scope.isDebtor = isDebtor();

                    $scope.isLender = isLender();
                });
        };

        fetchEntry();

        var getStatus = function(statusId) {
            return Entry.getStatus(statusId);
        };

        var isOpen = function() {
            return $scope.entry.status === 0;
        };

        var isAccepted = function() {
            return $scope.entry.status === 1;
        };

        var isRejected = function() {
            return $scope.entry.status === 2;
        };

        var isDeleted = function() {
            return $scope.entry.status === 3;
        } ;

        var isEditable = function() {
            return (isOpen() || isRejected());
        };

        var isAcceptable = function() {
            return (isOpen() || isRejected());
        };

        var isRejectable = function() {
            return !(isRejected() || isAccepted() || isDeleted());
        };

        var isDeletable = function() {
            return !(isAccepted() || isRejected() || isDeleted());
        };

        var isDebtor = function() {
            return  $scope.userData.ioweyouId == $scope.entry.debtor_id;
        };

        var isLender = function() {
            return  $scope.userData.ioweyouId == $scope.entry.lender_id;
        };

        var acceptEntry = function() {
            Entry.accept($scope.entry.id)
                .success(function(){
                    $scope.$emit('flashMessage', 'success', 'Entry accepted successfully.');
                    fetchEntry();
                });
        };

        var deleteEntry = function() {
            Entry.delete($scope.entry.id)
                .success(function(){
                    $scope.$emit('flashMessage', 'success', 'Entry deleted successfully.');
                    $location.path('/entry/list');
                });
        };

        var rejectEntry = function() {
            Entry.reject($scope.entry.id)
                .success(function(){
                    $scope.$emit('flashMessage', 'success', 'Entry rejected successfully.');
                    fetchEntry();
                });
        };

        $scope.getStatus = getStatus;

        $scope.deleteEntry = deleteEntry;

        $scope.rejectEntry = rejectEntry;

        $scope.acceptEntry = acceptEntry;

        $scope.modifyEntry = function() {

            $scope.buttonSave.label = 'Przetwarzanie...';
            $scope.buttonSave.disabled = true;

            Entry.modify($scope.entry.id, $scope.formData)
                .success(function(data) {
                    if(data.isModified) {
                        $scope.$emit('flashMessage', 'success', 'Wpis został zmodyfikowany poprawnie.');
                        $scope.buttonSave.disabled = false;
                        $scope.buttonSave.label = 'Zapisz';
                        fetchEntry();
                    } else {
                        $scope.$emit('flashMessage', 'danger', 'Żądanie zostało wysłane porpawnie, jednak wpis nie został utworzony. Spróbuj ponownie.');
                        $scope.buttonSave.label = 'Zapisz';
                        $scope.buttonSave.disabled = false;
                    }
                }).error(function(errors) {
                    $scope.formErrors = errors;
                    $scope.buttonSave.label = 'Zapisz';
                    $scope.buttonSave.disabled = false;
                });
        };

        $scope.hasError = function hasError(fieldName) {
            if($scope.formErrors[fieldName]) {
                return true;
            }

            return false;
        }

        $scope.toggleForm = function toggleForm() {
            $scope.formVisibility = !$scope.formVisibility;
        }

        $scope.openDatepickerFrom = function openDatepickerFrom($event) {
            $event.preventDefault();
            $event.stopPropagation();

            $scope.form.from.open = true;
        };

        $scope.openDatepickerTo = function openDatepickerTo($event) {
            $event.preventDefault();
            $event.stopPropagation();

            $scope.form.to.open = true;
        };
    }
);
