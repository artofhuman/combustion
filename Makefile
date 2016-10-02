RUN = docker-compose run --rm

test: up setup/bundler
	$(MAKE) test/mysql test/postgres test/sqlite


test/sqlite:
	${RUN} -e DB_ADAPTER=sqlite3 app bundle exec rspec spec

test/postgres:
	${RUN} -e DB_ADAPTER=postgresql -e DB_HOST=pg -e DB_USERNAME=postgres app bundle exec rspec spec

test/mysql:
	${RUN} -e DB_ADAPTER=mysql2 -e DB_HOST=mysql -e DB_USERNAME=root app bundle exec rspec spec

setup/volumes:
	docker volume ls -q | grep gems-ruby2 > /dev/null || docker volume create --name gems-ruby2

setup/bundler:
	${RUN} app bundle check || ${RUN} app bundle install -j 4


up: setup/volumes
	docker-compose up -d
	echo 'wait db initialization'
	sleep 10

down:
	docker-compose down

halt:
	docker-compose down --volumes

.PHONY: test setup up halt down
