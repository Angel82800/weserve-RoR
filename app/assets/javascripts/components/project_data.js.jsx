var data = [
    { id: '1', title: 'Description'},
    { id: '2', title: 'tasks' },
    { id: '3', title: 'NewsFeed' },
    { id: '4', title: 'Publish' }
]

var ProjectData = React.createClass({
    getInitialState: function() {
        return {
            projectSelected: this.props.project,
            projectUser: this.props.projectUser,
            projectOwner: this.props.projectOwner,
            projectAdminsIds: this.props.projectAdminsIds,
            currentUserId: this.props.currentUserId
        }
    },
    render: function () {
        return (
            <Tabs data={data} project={this.state.projectSelected} projectUser={this.state.projectUser}
                  projectOwner={this.state.projectOwner} currentUserId={this.state.currentUserId}
                  projectAdminsIds={this.state.projectAdminsIds}
            />
        )
    }
});