var Tabs = React.createClass({
    getInitialState: function () {
        return {
            activeTab: 0,
            editMode: false
        }
    },
    handleClick: function(index) {
        this.setState({activeTab: index})
        return false
    },
    handleInplaceEdit: function(e) {
        e.preventDefault();
        if (!this.state.editMode) {
            var projectId = $(e.target).data("makes-editable");
            makeEditable(projectId);
            this.state.editMode = true;
        }
        else {
            this.state.editMode = false;
        }
    },
    render: function () {
        var projectAdminsIds = this.props.projectAdminsIds;
        var currentUserId = this.props.currentUserId;
        var projectOwner = this.props.projectOwner;
        var project_id = this.props.project.id
        var user_id = this.props.projectUser.id
        if (currentUserId != 0) {
            if (projectOwner || ($.inArray(currentUserId, projectAdminsIds) != -1)){
                var editButton = <button data-makes-editable={this.props.project.id} id="editBtn"
                                         name="editBtn" className="button tiny radius margin-button"
                                         onClick={this.handleInplaceEdit}>Edit</button>
            }
        }

        return (
            <div className="top-margin">
                <dl className="tabs tabs-center">
                    {this.props.data.map(function (tab, index) {
                        var activeClass = this.state.activeTab === index ? 'active' : ''
                        return (
                            <dd className={'tab ' + activeClass} key={tab.id} id={tab.id} >
                                <a href={'#' + tab.title} onClick={this.handleClick.bind(this, index)}>{tab.title}</a>
                            </dd>
                        )
                    }, this)}
                </dl>
                <div className="tabs-content">
                    {this.props.data.map(function (tab, index) {
                        var activeClass = this.state.activeTab === index ? 'active' : ''
                        if (tab.title === 'Description'){
                            return (
                                <div className={'content ' + activeClass}  key={tab.id}>
                                    <div>
                                        <div className="admin-info">
                                            Created by: <a href={'/users/'+user_id}>{this.props.projectUser.display_name}</a> {institue}
                                            <div className="prof-pic"></div>
                                        </div>
                                        <div className="project-show-description" data-edit-alert="true">
                                            <div id="proj-desc">{this.props.project.description}</div>
                                            {editButton}
                                        </div>
                                    </div>

                                </div>
                            )
                        }
                        else if (tab.title === 'tasks'){
                            return (
                                <div className={'content ' + activeClass + ' center'} key={tab.id} >
                                    <span>Task Panel will Be Displayed Here.</span>
                                </div>
                            )
                        }
                        else if (tab.title === 'NewsFeed'){
                            return (
                                <div className={'content ' + activeClass + ' center'} key={tab.id} >
                                    <span>News Feed will Be Displayed Here.</span>
                                </div>
                            )
                        }
                        else if (tab.title === 'Publish'){
                            return (
                                <div className={'content ' + activeClass + ' center'} key={tab.id} >
                                    <span>Publish Section will Be Displayed Here.</span>
                                </div>
                            )
                        }

                    },this)}
                </div>
            </div>
        )
    }
});

