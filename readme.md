# Learning Ansible: Exercise 1

# Setup

To run this playbook, you'll need a `vars/secrets.yml` file. If you don't have
my password, you'll need to generate your own secrets file. You can generate
this by running `ruby secretsgen.rb` and following the instructions. By default
it assumes that you have a system ansible-vault password, but it allows you to
specify one or prompt for it. If you don't use a system-default password, you
will not be able to use the `runplaybook.rb` script. It's not recommended to
re-run this script after your `secrets.yml` has already been generated - the
playbook will fail because passwords will have been re-generated.

The playbook can then be run with the command
`ansible-playbook -i hosts main.yml` or by running `ruby runplaybook.rb` which
runs with what I consider to be sensible defaults. It also populates a log file,
`playbook.log`, which is the log of the output the last time the script was run.

# General Structure

This follows the standard ansible layout, with a master playbook (`main.yml`),
a `group_vars` folder for storing some default variables, a `roles` folder with
playbooks for each role that needs to be run, and a `vars` folder where
`secrets.yml` is stored.

## Roles

This folder is broken up into `aws`, `docker`, `mysql`, `nginx`, and `wordpress`
roles.

### AWS

This role spins up the EC2 instance on which the WordPress server will run. It
also collects information about the instance which will be used to control it
later, namely its IP address. It runs from the `controller` host group, which
is the machine that is used to manipulate EC2 instances. This role is
**_necessary_** for the other roles to run, because without it, there is no
information about the machine(s) to install WordPress on.

### Docker

This installs docker and its dependencies on the target system(s).

### MySQL

This installs the MySQL docker container, then runs some logic. It uses the
`mysql_root_password` variable in the `secrets.yml` file for the value of
MySQL's root password. It copies the `my.cnf` template to the `/tmp` directory
of the AWS machine, and from there copies it to the docker machine. Finally, it
fetches some information on the docker container, namely its
internally-accessible IP address, for later use.

### NGINX

This sets up the NGINX webserver that WordPress will run on. This includes
installing NGINX and copying over the `nginx.conf` template. However, there is
also a step to generate a self-signed SSL certificate. This is because, on this
server, there is the possibility of using the `/wp-admin` web page for
testing. In that case, since this instance is publicly accessible, we don't want
those credentials being sent over in plaintext. TODO: consider using
[CertBot](https://certbot.eff.org) to sign the keys automatically?

### WordPress

This gets into the meat of installing WordPress, and is the most complicated
step.

It first sets up the system for everything it will need to do involving
WordPress. This includes dependencies, as well as creating a user and group. At
this stage, it also initializes the wordpress database (iff it needs to) and
creates the wordpress user with appropriate permissions. It then installs
WordPress to a subdirectory in `/srv`, and changes ownership to the wordpress
user created earlier. Next, it copies appropriate config files over from
templates, so that WordPress will run correctly. Finally, it installs the
[`wp-cli`](http://wp-cli.org) tool used for controlling WordPress to
`/usr/bin/wp`, if it is not already present.

If the database was initialized (i.e. the database did not previously exist),
a series of handlers are triggered. Weather data will be downloaded from
[MetaWeather](https://www.metaweather.com), and a new post will be created with
that information. Because this is triggered by the creation of a new database,
it will be triggered when, and only when, a new wordpress installation/database
was created by this playbook.

# Notes

There are some inter-role dependencies specified within this project. For
example, the MySQL role depends on the Docker role. Look at
`roles/<role>/meta/main.yml` for more information.

The generator scripts are provided "as-is", and are rough around the edges.

In `roles/mysql/tasks/main.yml`, you may notice an inconsistency in the last
two steps. This may be an issue with my machine, or it may be a bug in ansible
(or both!). In the first one, single quotes are not escaped, and in the second
one they are. If the single quotes are escaped on the first one, it breaks. If
the single quotes are not escaped on the second one, it breaks. I don't know
what causes this inconsistency.
