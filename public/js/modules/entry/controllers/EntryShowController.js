angular.module('IOUApp')

    .controller('EntryShowController', ['$scope', "$routeParams", 'EntryFactory', 'AuthFactory',
    function($scope, $routeParams, EntryFactory, AuthFactory) {
        $scope.userData = AuthFactory.getUserData();
        $scope.entry = {};

        var fetchEntry = function() {
            EntryFactory.getOne($routeParams.id)
                .success(function(entry) {
                    $scope.entry = entry;
                });
        }

        var getStatus = function(statusId) {
            return EntryFactory.getStatus(statusId);
        }

        var isOpen = function() {
            return $scope.entry.status === 0;
        }

        var isAccepted = function() {
            return $scope.entry.status === 1;
        }

        var isRejected = function() {
            return $scope.entry.status === 2;
        }

        var isDeleted = function() {
            return $scope.entry.status === 3;
        }

        var isEditable = function() {
            return (isOpen() || isRejected());
        }

        var isAcceptable = function() {
            return (isOpen() || isRejected());
        }

        var isRejectable = function(entry) {
            return (!isAccepted() || isRejected() || isDeleted());
        }

        var isDeletable = function(entry) {
            return (!isAccepted() || isDeleted());
        }

        var isDebtor = function() {
            console.log('debtor_id', $scope.entry.debtor_id);
            console.log('user_id', $scope.userData.ioweyouId);
            return  $scope.userData.ioweyouId === $scope.entry.debtor_id;
        }

        var isLender = function() {
            return  $scope.userData.ioweyouId === $scope.entry.lender_id;
        }

        $scope.fetchEntry = fetchEntry;

        $scope.getStatus = getStatus;

        $scope.isOpen = isOpen;

        $scope.isAccepted = isAccepted;

        $scope.isRejected = isRejected;

        $scope.isDeleted = isDeleted;

        $scope.isEditable = isEditable;

        $scope.isAcceptable = isAcceptable;

        $scope.isRejectable = isRejectable;

        $scope.isDeletable = isDeletable;

        $scope.isDebtor = isDebtor;

        $scope.isLender = isLender;

        $scope.fetchEntry();
    }
]);
