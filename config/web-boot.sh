echo "accesskey: $AWS_ACCESS_KEY_ID" >> ~/.jgit
echo "secretkey: $AWS_SECRET_ACCESS_KEY" >> ~/.jgit

bundle exec rails server -p $PORT
