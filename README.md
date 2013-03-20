## Streetfiles Exporter
====================

Streetfiles Exporter is a small Ruby script which helping to export all user photos from graffiti portal http://streetfiles.org to local folder.
It also support export of photos user marked as "Loved" or "Bookmarked"

### Dependencies

To use the script you may have https://github.com/jnunemaker/httparty and https://github.com/whymirror/hpricot gems installed.

    $ gem install httparty
    $ gem install hpricot

### Installing streetfiles_exported

Clone the reposity

    $ git clone git@github.com:aliaksandrb/streetfiles_exporter.git

Or just copy export_streetfiles_pictures.rb file from it.

### Usage

Script has 3 download options supported:

  * -m - for photos user owner is
  * -l - for photos user loved
  * -b - for photos user bookmarked

So to download all your photos:

    $ cd to the directory with a script 
    $ ruby ./export_streetfiles_pictures.rb -m your_email 'your_password' (single equotes required)

All your pictures will be downloaded to the 'Streetfiles' folder in current path.

