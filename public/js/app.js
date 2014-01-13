angular.module('IOUApp', ['ngRoute', 'ezfb', 'ngCookies', 'ngAnimate', 'ui.bootstrap'])
    .config( function IOUAppConfig ( $routeProvider, $httpProvider, $FBProvider ) {
        'use strict';

        $routeProvider.when('/entry/list', {
            controller: 'EntryListController',
            templateUrl: 'public/templates/entry/index.html',
            publicAccess: false
        })
        .when('/entry/create', {
            controller: 'EntryCreateController',
            templateUrl: 'public/templates/entry/createMultiple.html',
            publicAccess: false
        })
        .when('/entry/give-back', {
            controller: 'EntryCreateController',
            templateUrl: 'public/templates/entry/createOne.html',
            publicAccess: false
        })
        .when('/entry/show/:id', {
            controller: 'EntryShowController',
            templateUrl: 'public/templates/entry/show.html',
            publicAccess: false
        })
        .when('/splash', {
            controller: 'SplashController',
            templateUrl: 'public/templates/splash/index.html',
            publicAccess: true
        })
        .when('/', {
            controller: 'DashboardController',
            templateUrl: 'public/templates/dashboard/index.html',
            publicAccess: false
        })
        .otherwise({
            template: 'Error 404'
        });

        $FBProvider.setInitParams({
            appId: '108723412644911'
        });

        $httpProvider.interceptors.push('HttpResponseInterceptor');
    })
    .run( function($rootScope, $location, AuthFactory ) {
        $rootScope.$on("$routeChangeStart", function (event, next, current) {
            if (next.publicAccess) {
                return;
            } else {
                if(!AuthFactory.isLogged()) {
                    $location.path('/splash');
                }
            }
        });
    });