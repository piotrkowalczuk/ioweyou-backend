angular.module('IOUApp')

    .controller('EntryShowController',
    function($scope, $routeParams, $location, EntryFactory, AuthFactory) {
        $scope.userData = AuthFactory.getUserData();
        $scope.entry = {};

        var fetchEntry = function() {

            EntryFactory.getOne($routeParams.id)
                .success(function(entry) {
                    $scope.entry = entry;

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
            return EntryFactory.getStatus(statusId);
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
            return (!isAccepted() || isRejected() || isDeleted());
        };

        var isDeletable = function() {
            return (!isAccepted() || isDeleted());
        };

        var isDebtor = function() {
            return  $scope.userData.ioweyouId == $scope.entry.debtor_id;
        };

        var isLender = function() {
            return  $scope.userData.ioweyouId == $scope.entry.lender_id;
        };

        var deleteEntry = function() {
            EntryFactory.delete($scope.entry.id)
                .success(function(){
                    $scope.$emit('flashMessage', 'success', 'Entry deleted successfully.');
                    $location.path('/entry/list');
                });
        };

        $scope.getStatus = getStatus;

        $scope.deleteEntry = deleteEntry;
    }
);
