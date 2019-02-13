# frozen_string_literal: true
BtcExchangeRate.create(rate: 1023.43)

users = []
projects = []
chatrooms = []

3.times do |i|
  params =
    {
      email: "user#{i}@weserve.io",
      first_name: "User #{i}",
      last_name: 'Test',
      username: "user_#{i}",
      password: "#{i}-weserve",
      password_confirmation: "#{i}-weserve",
      confirmed_at: Time.zone.now,
      role: :user,
      admin: false
    }
  users << (User.find_by_email(params[:email]) || User.create(params))
end

admin_params = {
  email: "test-admin@weserve.io",
  first_name: "Admin",
  last_name: 'Test',
  username: "admin",
  password: "admin-weserve",
  password_confirmation: "admin-weserve",
  confirmed_at: Time.zone.now,
  role: :user,
  admin: true
}

users << User.create(admin_params)

project_times = (rand * 4 + 2).to_i
puts "Creating #{project_times} projects"
project_times.times do
  user = users.sample
  id = (rand * 1_000_000 + 1).to_i
  project_params = [
    {
      title: "Review project #{id}",
      short_description: Faker::Lorem.sentence,
      description: Faker::Lorem.paragraph,
      country: Faker::Address.country,
      wiki_page_name: "Review project #{id}",
      state: user.admin? ? 'accepted' : 'pending',
      user: user
    }
  ]

  project_params.each do |params|
    project = Project.find_by_title(params[:title]) || Project.create(params)
    projects << project
    project_team = project.create_team(name: "Team#{project.id}")
    TeamMembership.create(team_member_id: user.id,
                          team_id: project_team.id, role: 1)
    user.create_activity(project, 'created')
    chatrooms << Chatroom.create_chatroom_with_groupmembers([user], 1, project)

    task_states = Task.aasm.states.map(&:name)
    task_times = (rand * 6 + 1).to_i
    puts "Creating #{task_times} tasks for project #{project.title}"
    task_times.times do
      state = task_states.sample
      budget = (rand + 20).round(2)
      task_params =
        {
          title: "#{state.to_s.camelcase} with #{budget} of budget",
          budget: budget,
          condition_of_execution: Faker::Lorem.sentence,
          proof_of_execution: Faker::Lorem.sentence,
          deadline: 1.week.from_now,
          project_id: project.id,
          state: state
        }
      task_user = users.sample
      service = TaskCreateService.new(task_params, task_user, project)
      service.create_task
      puts "  Task '#{service.task.title}' created "\
           "with user '#{task_user.username}'"
    end
  end
end

messages_times = (rand * 15 + 5).to_i
puts "Creating #{messages_times} messages"
messages_times.times do
  current_chatroom = chatrooms.sample
  user = users.sample
  group_message = GroupMessage.create(chatroom: current_chatroom,
                                      message: Faker::ChuckNorris.fact,
                                      user: user)
  puts "  Message #{group_message.id} where #{user.username}"\
       " writes '#{group_message.message}'"
end
