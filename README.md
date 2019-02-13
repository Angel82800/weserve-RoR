[![Build Status](https://travis-ci.com/YouServe/Main-App.svg?token=kiwczU62GarLsbEqnsyS&branch=fork_climate)](https://travis-ci.com/YouServe/Main-App) [![Maintainability](https://api.codeclimate.com/v1/badges/f0bedea219f45fe0580b/maintainability)](https://codeclimate.com/repos/589750a7e45655005f004703/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/f0bedea219f45fe0580b/test_coverage)](https://codeclimate.com/repos/589750a7e45655005f004703/test_coverage)

# Requirements

- Ruby 2.2.1
- Rails 4.2.5.1
- PostgreSQL
- NodeJS 4.x
- [Mediawiki](https://mediawiki.org) 1.25+

# Components

Main application is a RoR website, but it depends on set of 3rd paty tools:

- Mediawiki - running as separate application, provides web-API to store some texts from main app

# Steps to run the app

### 1. Prepare environment

* Install & configure Git
* Install & configure PostgreSQL database
* Install NodeJS
* Install an image processing tool:

     For OSX: `brew install graphicsmagick` OR  `brew install imagemagick`

     For Ubuntu: `apt-get install graphicsmagick` OR `apt-get install imagemagick`

* Install PhantomJS browser for acceptance tests:

     For OSX: `brew install phantomjs`

     For Ubuntu: `apt-get install phantomjs`

* Clone the repository and perform `bundle install`

### 2. Get necessary tokens

* Create an account at https://stripe.com
* Not necessary, but recommended: create app tokens at your [Facebook][1], [Twitter][2] and Google accounts

### 3. Configure Mediawiki

This step requires you either configure local Mediawiki instance or use our staging Mediawiki instance.
This step can be omited for now, ask other developers for Mediawiki credentials.

### 4. Create configuration files

* Copy `config/application.yml.exampe` to `config/application.yml`
* Fill values following comments in this file
* Copy `config/database.yml.example` to `config/database.yml` and specify yur PostgreSQL credentials

### 5. Migrate database

* Being in app directory run `RAILS_ENV=development bundle exec rake db:create db:schema:load db:migrate`
* If necessary, run `RAILS_ENV=development bundle exec rake db:seed` to populate database with sample data

### 6. Configure ENV varialbes

* See `application.yml` for details

### 7. Run the application

* In app directory run `RAILS_ENV=development rails server`

# Steps to run test

* Within app directory run `RAILS_ENV=test bundle exec rspec --format documentation`

# Tools

* ...

# Translation

Application uses i18n files to render strings in different languages, these files are located in `config/localtes` directory,
files for each language are grouped in own sub-directory, eg: `config/locales/en`. Strings are separated by context using own file
for each context, for example: strings for main page are located in `config/locales/en/landing.en.yml`. Note that each file also
explicitly indicates language it belongs to by applying `en` suffix to its name.

## i18n files format

Locale files are formatted as YAML and usually have hierarchical structure, though, this fact is not important for
translation process, but you can learn more about YAML [here](http://docs.ansible.com/ansible/YAMLSyntax.html) if you want.

Basically regardless of file structure there are 2 main entities: **key** and **value**, first one is represented as term
without spaces and located *at left*, second one - wrapped into single or double quotes and contains some text.

Goal of translation process is to translate all **values** but do not touch the keys!

Example: file in english

```yaml
en:
  landing:
    hero-title: "Turn your followers into a task force"
    hero-subtitle: "<span>Share your</span> vision and your audience will make it happen"
    hero-collaboration-title: "Engage your social network to"
    copy_right: "%{year} WeServe.io Beta"
```

Example: file translated to Russian

```yaml
en:
  landing:
    hero-title: "Превратите ваших последвателей в силу"
    hero-subtitle: "<span>Поделитесь своей</span> идеей и ваша аудитория воплотит ее"
    hero-collaboration-title: "Вовлеките ваши социальные связи"
    copy_right: "%{year} WeServe.io Бета версия"
```

**Note**: sometime value strings will contain special constructions like `%{year}`, HTML-markup elements like `<span>` or
links like `http://www.site.com`. You **should not** change these parts in any way so just keep them during translation.

## How to translate

Lets say we're going to translate some text on from English to Russian, he is the steps we need to perform:

1. Copy contents of `config/locales/en` into `config/locales/ru`
2. Rename all files suffixes to `ru` so, for example `landing.en.yml` becomes `landing.ru.yml`
3. Edit each file and replace all English string content with Russian text following example above

**Note**: you can use [YAML validator](http://www.yamllint.com/) to ensure you did not make an error during translation.

# Create first user

In case you just started and you dont have any data in your database. Make sure to run command

- bundle exec rake db:create db:migrate db:seed
- start server by typing: bundle exec rails s
- in browser go to localhost:3000 and use the UI to register a new user
- in terminal window run command: bundle exec rails c
- when console loads type: 
    user = User.first
    user.confirm

You should have a confirmed user now in your db

# Troubleshooting

* To be added...

-

...

[1]: https://developers.facebook.com/apps
[2]: https://apps.twitter.com/
