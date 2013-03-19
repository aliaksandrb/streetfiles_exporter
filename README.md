## Streetfiles Exporter
====================

Streetfiles Exporter is a small Ruby script which exporting all user photos from graffiti portal http://streetfiles.org to local folder.

### Dependencies

To use the script you may have https://github.com/jnunemaker/httparty and https://github.com/whymirror/hpricot gems installed.

    $ gem install httparty
    $ gem install hpricot

### Installing streetfiles_exported

Just clone the reposity

    $ git clone git@github.com:aliaksandrb/streetfiles_exporter.git

Or just copy export_streetfiles_pictures.rb file from it.

### Usage

    $ cd to the directory with a script 
    $ ruby ./export_streetfiles_pictures.rb your_email 'your_password' (single equotes required)

All your pictures will be downloaded to 'Streetfiles' folder in current path.

