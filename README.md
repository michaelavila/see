# SEE

The purpose of see is to provide a useful view of all of the information related to your project concisely and in a single command. Now projects vary quite a lot and so this versatility is achieved through plugins. Here is what it looks like to "see" this project:

![Screenshot](doc/screenshot.png)

## Installation

Use rubygems:

    gem install see

Or add it to your Gemfile

    gem 'see'

## Configure Your Project

All you need is a file named `see.yml` at the root of your project that contains all or some of the following configurations:

    github:
      account: michaelavila
      repository: see
    travis:
      repository: michaelavila/see
    circle:
      account: michaelavila
      repository: see
    pivotal:
      project: 1016378

You will obviously need to change the values to your own. These are taken directly from this projects [configuration](see.yml)

## Plugins

A list of plugins can be found [here](lib/see/plugins). Documentation for a particular plugin will be located in that plugin's source. Currently, all plugins are bundled with see and so there is no use to install external plugins. I imagine this changing possibly.
