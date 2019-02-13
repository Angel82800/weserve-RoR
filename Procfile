web: if [ -v HEROKU_APP_NAME ]; then export default_url=$HEROKU_APP_NAME.herokuapp.com; fi; puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: if [ -v HEROKU_APP_NAME ]; then export default_url=$HEROKU_APP_NAME.herokuapp.com; fi;  bundle exec rake jobs:work
clock: if [ -v HEROKU_APP_NAME ]; then export default_url=$HEROKU_APP_NAME.herokuapp.com; fi;  bundle exec clockwork app/clock.rb
release: rake db:migrate