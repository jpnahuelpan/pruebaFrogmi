FROM ruby:3.3

WORKDIR /frogmiback

COPY . /frogmiback/

RUN bundle install

EXPOSE 4567

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:4567", "-e", "development"]