export class GroupsController {
  constructor ($scope, Group) {
    'ngInject';

    Group.query().then(groups => $scope.groups = groups);
  }
}
