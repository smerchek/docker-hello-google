FROM phusion/passenger-ruby21:0.9.10

EXPOSE 3000

# Enable nginx/passenger
RUN rm -f /etc/service/nginx/down

# Disable SSH
# Some discussion on this: https://news.ycombinator.com/item?id=7950326
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Install rails dependencies
RUN apt-get update
RUN apt-get install sqlite3 libsqlite3-dev

# Install gems--do this early to avoid cache invalidation
ADD Gemfile* /home/app/webapp/
WORKDIR /home/app/webapp
RUN bundle install

# Copy in app and config files
ADD nginx/rails-env.conf /etc/nginx/main.d/
ADD nginx/webapp.conf /etc/nginx/sites-enabled/
ADD . /home/app/webapp

# Install "production" database (for demo purposes only)
WORKDIR /home/app/webapp
RUN RAILS_ENV=production rake db:migrate

# Run runit init system
CMD ["/sbin/my_init"]
